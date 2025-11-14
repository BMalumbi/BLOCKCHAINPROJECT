// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DiasporaValidatorRegistry - Gestion des validateurs de confiance
/// @notice Registre pour certifier et gérer les agents validateurs
contract DiasporaValidatorRegistry {
    
    // ==================== Structures ====================
    
    struct ValidatorProfile {
        address validatorAddress;
        string organizationName;
        string country;
        string licenseNumber;
        bool isCertified;
        uint256 certificationDate;
        uint256 totalValidations;
        uint256 successfulValidations;
        uint256 disputedValidations;
        uint256 reputationScore;     // Sur 100
    }
    
    // ==================== Variables d'État ====================
    
    address public owner;
    
    mapping(address => ValidatorProfile) public validators;
    mapping(address => bool) public isCertifiedValidator;
    
    address[] public validatorList;
    
    // ==================== Événements ====================
    
    event ValidatorCertified(address indexed validator, string organizationName);
    event ValidatorRevoked(address indexed validator, string reason);
    event ValidationRecorded(address indexed validator, bool successful);
    event ReputationUpdated(address indexed validator, uint256 newScore);
    
    // ==================== Modificateurs ====================
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    // ==================== Constructeur ====================
    
    constructor() {
        owner = msg.sender;
    }
    
    // ==================== Fonctions Principales ====================
    
    function registerValidator(
        string memory _organizationName,
        string memory _country,
        string memory _licenseNumber
    ) external {
        require(!isCertifiedValidator[msg.sender], "Already registered");
        require(bytes(_organizationName).length > 0, "Organization name required");
        
        validators[msg.sender] = ValidatorProfile({
            validatorAddress: msg.sender,
            organizationName: _organizationName,
            country: _country,
            licenseNumber: _licenseNumber,
            isCertified: false,
            certificationDate: 0,
            totalValidations: 0,
            successfulValidations: 0,
            disputedValidations: 0,
            reputationScore: 50
        });
    }
    
    function certifyValidator(address _validator) external onlyOwner {
        require(validators[_validator].validatorAddress != address(0), "Validator not registered");
        
        validators[_validator].isCertified = true;
        validators[_validator].certificationDate = block.timestamp;
        isCertifiedValidator[_validator] = true;
        
        validatorList.push(_validator);
        
        emit ValidatorCertified(_validator, validators[_validator].organizationName);
    }
    
    function revokeValidator(address _validator, string memory _reason) external onlyOwner {
        require(isCertifiedValidator[_validator], "Not a certified validator");
        
        validators[_validator].isCertified = false;
        isCertifiedValidator[_validator] = false;
        
        emit ValidatorRevoked(_validator, _reason);
    }
    
    function recordValidation(address _validator, bool _successful) external {
        require(isCertifiedValidator[_validator], "Not certified");
        
        ValidatorProfile storage profile = validators[_validator];
        profile.totalValidations++;
        
        if (_successful) {
            profile.successfulValidations++;
        } else {
            profile.disputedValidations++;
        }
        
        // Calculer nouveau score de réputation
        if (profile.totalValidations > 0) {
            profile.reputationScore = (profile.successfulValidations * 100) / profile.totalValidations;
        }
        
        emit ValidationRecorded(_validator, _successful);
        emit ReputationUpdated(_validator, profile.reputationScore);
    }
    
    // ==================== Fonctions de Vue ====================
    
    function getValidatorProfile(address _validator)
        external
        view
        returns (
            string memory organizationName,
            string memory country,
            bool certified,
            uint256 totalValidations,
            uint256 successRate,
            uint256 reputationScore
        )
    {
        ValidatorProfile memory profile = validators[_validator];
        
        uint256 rate = 0;
        if (profile.totalValidations > 0) {
            rate = (profile.successfulValidations * 100) / profile.totalValidations;
        }
        
        return (
            profile.organizationName,
            profile.country,
            profile.isCertified,
            profile.totalValidations,
            rate,
            profile.reputationScore
        );
    }
    
    function getAllValidators() external view returns (address[] memory) {
        return validatorList;
    }
    
    function getValidatorCount() external view returns (uint256) {
        return validatorList.length;
    }
}
