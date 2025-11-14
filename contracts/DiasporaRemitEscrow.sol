// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DiasporaRemitEscrow - Système d'Escrow Blockchain pour les Transferts de la Diaspora  
/// @notice Contrat d'escrow avancé avec validation de conditions et multi-transferts
/// @dev Version modulaire optimisée < 24KB - Profils dans DiasporaUserRegistry et DiasporaValidatorRegistry
/// @author Ronny - Diaspora Remittance Project

// Interfaces pour les contrats modulaires
interface IUserRegistry {
    function isRegistered(address _user) external view returns (bool);
    function isUserVerified(address _user) external view returns (bool);
    function updateReputation(address _user, uint256 _newScore) external;
}

interface IValidatorRegistry {
    function isCertifiedValidator(address _validator) external view returns (bool);
    function recordValidation(address _validator, bool _successful) external;
}

contract DiasporaRemitEscrow {
    
    struct Transfer {
        uint256 transferId;
        address sender;
        address recipient;
        address validator;
        uint256 amount;
        uint256 deadline;
        TransferStatus status;
        string purpose;
        string validationNote;
        uint256 createdAt;
        uint256 releasedAt;
        bool isRefunded;
    }
    
    enum TransferStatus { Created, Funded, Validated, Completed, Refunded, Disputed }
    
    address public owner;
    uint256 public platformFeePercentage = 1;
    uint256 public totalTransfers;
    uint256 public totalValueLocked;
    
    mapping(uint256 => Transfer) public transfers;
    mapping(address => uint256[]) public senderTransfers;
    mapping(address => uint256[]) public recipientTransfers;
    mapping(address => uint256[]) public validatorTransfers;
    
    uint256 private locked = 1;
    
    // Interfaces pour contrats modulaires
    IUserRegistry public userRegistry;
    IValidatorRegistry public validatorRegistry;
    
    event TransferCreated(uint256 indexed transferId, address indexed sender, address indexed recipient, address validator, uint256 amount, string purpose);
    event TransferFunded(uint256 indexed transferId, uint256 amount, uint256 deadline);
    event TransferValidated(uint256 indexed transferId, address indexed validator, string note);
    event TransferCompleted(uint256 indexed transferId, address indexed recipient, uint256 amount, uint256 platformFee);
    event TransferRefunded(uint256 indexed transferId, address indexed sender, uint256 amount);
    event TransferDisputed(uint256 indexed transferId, address indexed disputedBy, string reason);
    event DisputeResolved(uint256 indexed transferId, address resolver, bool favorRecipient, uint256 recipientAmount, uint256 senderAmount);
    event RecipientUpdated(uint256 indexed transferId, address oldRecipient, address newRecipient);
    event ValidatorUpdated(uint256 indexed transferId, address oldValidator, address newValidator);
    event DeadlineExtended(uint256 indexed transferId, uint256 oldDeadline, uint256 newDeadline);
    
    error Unauthorized(address caller);
    error InvalidAddress();
    error InvalidAmount();
    error InvalidStatus(TransferStatus current, TransferStatus required);
    error TransferNotFound(uint256 transferId);
    error DeadlinePassed();
    error DeadlineNotPassed();
    error AlreadyFunded();
    error NotFunded();
    error AlreadyRefunded();
    error TransferFailed();
    error ReentrancyDetected();
    error InvalidPercentage();
    error EmptyPurpose();
    
    modifier nonReentrant() {
        if (locked != 1) revert ReentrancyDetected();
        locked = 2;
        _;
        locked = 1;
    }
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized(msg.sender);
        _;
    }
    
    modifier transferExists(uint256 _transferId) {
        if (_transferId >= totalTransfers) revert TransferNotFound(_transferId);
        _;
    }
    
    modifier onlySender(uint256 _transferId) {
        if (transfers[_transferId].sender != msg.sender) revert Unauthorized(msg.sender);
        _;
    }
    
    modifier onlyRecipient(uint256 _transferId) {
        if (transfers[_transferId].recipient != msg.sender) revert Unauthorized(msg.sender);
        _;
    }
    
    modifier onlyValidator(uint256 _transferId) {
        if (transfers[_transferId].validator != msg.sender) revert Unauthorized(msg.sender);
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function setUserRegistry(address _registry) external onlyOwner {
        userRegistry = IUserRegistry(_registry);
    }
    
    function setValidatorRegistry(address _registry) external onlyOwner {
        validatorRegistry = IValidatorRegistry(_registry);
    }
    
    function createTransfer(
        address _recipient,
        address _validator,
        string memory _purpose,
        uint256 _deadlineSeconds
    ) public returns (uint256) {
        if (_recipient == address(0) || _validator == address(0)) revert InvalidAddress();
        if (bytes(_purpose).length == 0) revert EmptyPurpose();
        if (_deadlineSeconds < 1 days) revert InvalidAmount();
        
        uint256 transferId = totalTransfers;
        
        transfers[transferId] = Transfer({
            transferId: transferId,
            sender: msg.sender,
            recipient: _recipient,
            validator: _validator,
            amount: 0,
            deadline: block.timestamp + _deadlineSeconds,
            status: TransferStatus.Created,
            purpose: _purpose,
            validationNote: "",
            createdAt: block.timestamp,
            releasedAt: 0,
            isRefunded: false
        });
        
        senderTransfers[msg.sender].push(transferId);
        recipientTransfers[_recipient].push(transferId);
        validatorTransfers[_validator].push(transferId);
        
        totalTransfers++;
        
        emit TransferCreated(transferId, msg.sender, _recipient, _validator, 0, _purpose);
        
        return transferId;
    }
    
    function fundTransfer(uint256 _transferId) 
        external 
        payable 
        transferExists(_transferId)
        onlySender(_transferId)
        nonReentrant
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (transfer.status != TransferStatus.Created) {
            revert InvalidStatus(transfer.status, TransferStatus.Created);
        }
        if (msg.value == 0) revert InvalidAmount();
        if (transfer.amount > 0) revert AlreadyFunded();
        
        transfer.amount = msg.value;
        transfer.status = TransferStatus.Funded;
        
        totalValueLocked += msg.value;
        
        emit TransferFunded(_transferId, msg.value, transfer.deadline);
    }
    
    function createAndFundTransfer(
        address _recipient,
        address _validator,
        string memory _purpose,
        uint256 _deadlineSeconds
    ) external payable returns (uint256) {
        if (msg.value == 0) revert InvalidAmount();
        
        uint256 transferId = createTransfer(_recipient, _validator, _purpose, _deadlineSeconds);
        
        Transfer storage transfer = transfers[transferId];
        transfer.amount = msg.value;
        transfer.status = TransferStatus.Funded;
        
        totalValueLocked += msg.value;
        
        emit TransferFunded(transferId, msg.value, transfer.deadline);
        
        return transferId;
    }
    
    function validateTransfer(uint256 _transferId, string calldata _note)
        external
        transferExists(_transferId)
        onlyValidator(_transferId)
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (transfer.status != TransferStatus.Funded) {
            revert InvalidStatus(transfer.status, TransferStatus.Funded);
        }
        if (block.timestamp > transfer.deadline) revert DeadlinePassed();
        
        transfer.status = TransferStatus.Validated;
        transfer.validationNote = _note;
        
        // Enregistrer la validation dans le registre des validateurs
        if (address(validatorRegistry) != address(0)) {
            validatorRegistry.recordValidation(msg.sender, true);
        }
        
        emit TransferValidated(_transferId, msg.sender, _note);
    }
    
    function withdrawFunds(uint256 _transferId)
        external
        transferExists(_transferId)
        onlyRecipient(_transferId)
        nonReentrant
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (transfer.status != TransferStatus.Validated) {
            revert InvalidStatus(transfer.status, TransferStatus.Validated);
        }
        if (transfer.amount == 0) revert NotFunded();
        
        uint256 totalAmount = transfer.amount;
        uint256 platformFee = (totalAmount * platformFeePercentage) / 100;
        uint256 recipientAmount = totalAmount - platformFee;
        
        transfer.status = TransferStatus.Completed;
        transfer.releasedAt = block.timestamp;
        
        totalValueLocked -= totalAmount;
        
        // Mettre à jour la réputation de l'expéditeur dans le registre
        if (address(userRegistry) != address(0)) {
            _updateUserReputation(transfer.sender);
        }
        
        (bool success, ) = payable(transfer.recipient).call{value: recipientAmount}("");
        if (!success) revert TransferFailed();
        
        emit TransferCompleted(_transferId, transfer.recipient, recipientAmount, platformFee);
    }
    
    function refundTransfer(uint256 _transferId)
        external
        transferExists(_transferId)
        nonReentrant
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (transfer.status != TransferStatus.Funded) {
            revert InvalidStatus(transfer.status, TransferStatus.Funded);
        }
        if (block.timestamp <= transfer.deadline) revert DeadlineNotPassed();
        if (transfer.isRefunded) revert AlreadyRefunded();
        
        uint256 refundAmount = transfer.amount;
        
        transfer.status = TransferStatus.Refunded;
        transfer.isRefunded = true;
        
        totalValueLocked -= refundAmount;
        
        (bool success, ) = payable(transfer.sender).call{value: refundAmount}("");
        if (!success) revert TransferFailed();
        
        emit TransferRefunded(_transferId, transfer.sender, refundAmount);
    }
    
    function raiseDispute(uint256 _transferId, string calldata _reason)
        external
        transferExists(_transferId)
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (msg.sender != transfer.sender && msg.sender != transfer.recipient) {
            revert Unauthorized(msg.sender);
        }
        
        if (transfer.status != TransferStatus.Validated && transfer.status != TransferStatus.Funded) {
            revert InvalidStatus(transfer.status, TransferStatus.Validated);
        }
        
        transfer.status = TransferStatus.Disputed;
        
        emit TransferDisputed(_transferId, msg.sender, _reason);
    }
    
    function resolveDispute(uint256 _transferId, uint8 _percentageToRecipient)
        external
        onlyOwner
        transferExists(_transferId)
        nonReentrant
    {
        Transfer storage transfer = transfers[_transferId];
        
        if (transfer.status != TransferStatus.Disputed) {
            revert InvalidStatus(transfer.status, TransferStatus.Disputed);
        }
        if (_percentageToRecipient > 100) revert InvalidPercentage();
        
        uint256 totalAmount = transfer.amount;
        uint256 recipientAmount = (totalAmount * _percentageToRecipient) / 100;
        uint256 senderAmount = totalAmount - recipientAmount;
        
        transfer.status = TransferStatus.Completed;
        transfer.releasedAt = block.timestamp;
        
        totalValueLocked -= totalAmount;
        
        if (recipientAmount > 0) {
            (bool successRecipient, ) = payable(transfer.recipient).call{value: recipientAmount}("");
            if (!successRecipient) revert TransferFailed();
        }
        
        if (senderAmount > 0) {
            (bool successSender, ) = payable(transfer.sender).call{value: senderAmount}("");
            if (!successSender) revert TransferFailed();
        }
        
        emit DisputeResolved(_transferId, msg.sender, _percentageToRecipient > 50, recipientAmount, senderAmount);
    }
    
    function updateRecipient(uint256 _transferId, address _newRecipient)
        external
        transferExists(_transferId)
        onlySender(_transferId)
    {
        if (_newRecipient == address(0)) revert InvalidAddress();
        Transfer storage transfer = transfers[_transferId];
        if (transfer.status != TransferStatus.Created) {
            revert InvalidStatus(transfer.status, TransferStatus.Created);
        }
        address oldRecipient = transfer.recipient;
        transfer.recipient = _newRecipient;
        emit RecipientUpdated(_transferId, oldRecipient, _newRecipient);
    }
    
    function updateValidator(uint256 _transferId, address _newValidator)
        external
        transferExists(_transferId)
        onlySender(_transferId)
    {
        if (_newValidator == address(0)) revert InvalidAddress();
        Transfer storage transfer = transfers[_transferId];
        if (transfer.status != TransferStatus.Created && transfer.status != TransferStatus.Funded) {
            revert InvalidStatus(transfer.status, TransferStatus.Created);
        }
        address oldValidator = transfer.validator;
        transfer.validator = _newValidator;
        emit ValidatorUpdated(_transferId, oldValidator, _newValidator);
    }
    
    function extendDeadline(uint256 _transferId, uint256 _additionalSeconds)
        external
        transferExists(_transferId)
        onlySender(_transferId)
    {
        Transfer storage transfer = transfers[_transferId];
        if (transfer.status != TransferStatus.Funded) {
            revert InvalidStatus(transfer.status, TransferStatus.Funded);
        }
        if (block.timestamp > transfer.deadline) revert DeadlinePassed();
        uint256 oldDeadline = transfer.deadline;
        transfer.deadline += _additionalSeconds;
        emit DeadlineExtended(_transferId, oldDeadline, transfer.deadline);
    }
    
    function updatePlatformFee(uint256 _newFeePercentage) external onlyOwner {
        if (_newFeePercentage > 10) revert InvalidPercentage();
        platformFeePercentage = _newFeePercentage;
    }
    
    function getTransfer(uint256 _transferId)
        external
        view
        transferExists(_transferId)
        returns (
            address sender,
            address recipient,
            address validator,
            uint256 amount,
            uint256 deadline,
            TransferStatus status,
            string memory purpose,
            string memory validationNote,
            uint256 createdAt,
            uint256 releasedAt,
            bool isRefunded
        )
    {
        Transfer memory t = transfers[_transferId];
        return (t.sender, t.recipient, t.validator, t.amount, t.deadline, t.status, t.purpose, t.validationNote, t.createdAt, t.releasedAt, t.isRefunded);
    }
    
    function getSenderTransfers(address _sender) external view returns (uint256[] memory) {
        return senderTransfers[_sender];
    }
    
    function getRecipientTransfers(address _recipient) external view returns (uint256[] memory) {
        return recipientTransfers[_recipient];
    }
    
    function getValidatorTransfers(address _validator) external view returns (uint256[] memory) {
        return validatorTransfers[_validator];
    }
    
    function isUserVerified(address _user) external view returns (bool) {
        if (address(userRegistry) == address(0)) return false;
        return userRegistry.isUserVerified(_user);
    }
    
    function isValidatorCertified(address _validator) external view returns (bool) {
        if (address(validatorRegistry) == address(0)) return false;
        return validatorRegistry.isCertifiedValidator(_validator);
    }
    
    function getTransferStatus(uint256 _transferId)
        external
        view
        transferExists(_transferId)
        returns (
            TransferStatus status,
            bool isFunded,
            bool isValidated,
            bool isCompleted,
            bool isRefunded,
            bool canRefund,
            uint256 timeRemaining
        )
    {
        Transfer memory t = transfers[_transferId];
        bool _canRefund = (t.status == TransferStatus.Funded && block.timestamp >= t.deadline);
        uint256 _timeRemaining = t.deadline > block.timestamp ? t.deadline - block.timestamp : 0;
        return (t.status, t.amount > 0, t.status == TransferStatus.Validated || t.status == TransferStatus.Completed, t.status == TransferStatus.Completed, t.isRefunded, _canRefund, _timeRemaining);
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    function getPlatformStats() external view returns (uint256 _totalTransfers, uint256 _totalValueLocked, uint256 _platformFeePercentage) {
        return (totalTransfers, totalValueLocked, platformFeePercentage);
    }
    
    function _updateUserReputation(address _user) internal {
        uint256[] memory userTransfers = senderTransfers[_user];
        if (userTransfers.length > 0) {
            uint256 successful = 0;
            uint256 total = userTransfers.length > 100 ? 100 : userTransfers.length;
            
            for (uint256 i = 0; i < total; i++) {
                if (transfers[userTransfers[i]].status == TransferStatus.Completed) {
                    successful++;
                }
            }
            
            uint256 newScore = (successful * 100) / total;
            userRegistry.updateReputation(_user, newScore);
        }
    }
    
    receive() external payable {
        revert("Use createAndFundTransfer() or fundTransfer()");
    }
    
    fallback() external payable {
        revert("Invalid function call");
    }
}
