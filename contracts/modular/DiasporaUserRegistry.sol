// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DiasporaUserRegistry - Gestion des profils utilisateurs
/// @notice Registre pour gérer les profils des expéditeurs, bénéficiaires et validateurs
contract DiasporaUserRegistry {
    
    // ==================== Structures ====================
    
    struct UserProfile {
        address userAddress;
        string name;
        string country;
        UserType userType;
        bool isVerified;
        uint256 registrationDate;
        uint256 reputationScore;    // Score sur 100
        string kycDocumentHash;      // Hash IPFS du document KYC
    }
    
    enum UserType {
        Sender,      // Expéditeur (diaspora)
        Recipient,   // Bénéficiaire
        Validator,   // Validateur/Agent
        Both         // Peut être les deux
    }
    
    // ==================== Variables d'État ====================
    
    address public owner;
    address public mainContract;
    
    mapping(address => UserProfile) public userProfiles;
    mapping(address => bool) public isRegistered;
    
    uint256 public totalUsers;
    
    // ==================== Événements ====================
    
    event UserRegistered(address indexed user, string name, UserType userType);
    event UserVerified(address indexed user, address indexed verifier);
    event ProfileUpdated(address indexed user);
    event ReputationUpdated(address indexed user, uint256 newScore);
    
    // ==================== Modificateurs ====================
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyMainContract() {
        require(msg.sender == mainContract, "Only main contract");
        _;
    }
    
    // ==================== Constructeur ====================
    
    constructor() {
        owner = msg.sender;
    }
    
    function setMainContract(address _mainContract) external onlyOwner {
        mainContract = _mainContract;
    }
    
    // ==================== Fonctions Principales ====================
    
    function registerUser(
        string memory _name,
        string memory _country,
        UserType _userType
    ) external {
        require(!isRegistered[msg.sender], "Already registered");
        require(bytes(_name).length > 0, "Name required");
        
        userProfiles[msg.sender] = UserProfile({
            userAddress: msg.sender,
            name: _name,
            country: _country,
            userType: _userType,
            isVerified: false,
            registrationDate: block.timestamp,
            reputationScore: 50,
            kycDocumentHash: ""
        });
        
        isRegistered[msg.sender] = true;
        totalUsers++;
        
        emit UserRegistered(msg.sender, _name, _userType);
    }
    
    function updateProfile(
        string memory _name,
        string memory _country
    ) external {
        require(isRegistered[msg.sender], "Not registered");
        
        UserProfile storage profile = userProfiles[msg.sender];
        profile.name = _name;
        profile.country = _country;
        
        emit ProfileUpdated(msg.sender);
    }
    
    function verifyUser(address _user, string memory _kycHash) external onlyOwner {
        require(isRegistered[_user], "User not registered");
        
        userProfiles[_user].isVerified = true;
        userProfiles[_user].kycDocumentHash = _kycHash;
        
        emit UserVerified(_user, msg.sender);
    }
    
    function updateReputation(address _user, uint256 _newScore) external onlyMainContract {
        require(isRegistered[_user], "User not registered");
        require(_newScore <= 100, "Score must be 0-100");
        
        userProfiles[_user].reputationScore = _newScore;
        
        emit ReputationUpdated(_user, _newScore);
    }
    
    // ==================== Fonctions de Vue ====================
    
    function getUserProfile(address _user)
        external
        view
        returns (
            string memory name,
            string memory country,
            UserType userType,
            bool verified,
            uint256 reputation
        )
    {
        UserProfile memory profile = userProfiles[_user];
        return (
            profile.name,
            profile.country,
            profile.userType,
            profile.isVerified,
            profile.reputationScore
        );
    }
    
    function isUserVerified(address _user) external view returns (bool) {
        return userProfiles[_user].isVerified;
    }
}
