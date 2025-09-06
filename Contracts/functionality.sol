// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Tokens.sol";

contract ReliefChainFunctionality is AccessControl {
    bytes32 public constant BENEFACTOR_ROLE = keccak256("BENEFACTOR_ROLE");

    ReliefChain public reliefChainToken;
    mapping(uint => address) public achievements;

    event BenefactorAdded(address indexed addr);
    event BenefactorRemoved(address indexed addr);
    event Award(address indexed from, address indexed to, uint indexed atype, uint amount, uint date);

    constructor(address _reliefChainTokenAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        reliefChainToken = ReliefChain(_reliefChainTokenAddress);
    }

    function addBenefactor(address _addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BENEFACTOR_ROLE, _addr);
        emit BenefactorAdded(_addr);
    }

    function removeBenefactor(address _addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(BENEFACTOR_ROLE, _addr);
        emit BenefactorRemoved(_addr);
    }

    function addAchievement(uint _index) public onlyRole(BENEFACTOR_ROLE) returns (bool) {
        require(achievements[_index] == address(0), "Achievement already claimed");
        achievements[_index] = msg.sender;
        return true;
    }

    
    function awardAchievement(address _user, uint _aType, uint _amount) public onlyRole(BENEFACTOR_ROLE) {
        require(_amount <= reliefChainToken.balanceOf(address(this)), "Insufficient token balance in contract");

        
        if (_amount > 0) {
            reliefChainToken.transfer(_user, _amount);
        }
        emit Award(msg.sender, _user, _aType, _amount, block.timestamp);
    }
}