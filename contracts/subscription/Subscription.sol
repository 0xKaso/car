// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Subscription {
    struct SubConfig {
        uint price;
        uint period;
    }

    SubConfig subConfig;

    mapping (uint => uint) tokenLifespan;
    event SubscribeTokenUpdate(address caller,uint tokenId, uint expiration);

    function setSubConfig(SubConfig memory subConfig_) external onlyManager2 {
        subConfig = subConfig_;
    }
    
    function extendTokenSubscription(uint tokenId, uint times) external payable{
        uint payAmount = times * subConfig.price;
        uint extendTime = times * subConfig.period;

        require(msg.value >= payAmount,"ERR_ETHER_NOT_ENOUGH");

        tokenLifespan[tokenId] == 0
            ? tokenLifespan[tokenId] = block.timestamp + extendTime
            : tokenLifespan[tokenId] += extendTime; 

        emit SubscribeTokenUpdate(msg.sender, tokenId, tokenLifespan[tokenId]);
    }
    
    function revokeTokenSubscription(uint tokenId) external {
        delete tokenLifespan[tokenId];
        emit SubscribeTokenUpdate(msg.sender, tokenId, tokenLifespan[tokenId]);
    }
    
    function hasExpired(uint tokenId) external view returns (bool){
        return tokenLifespan[tokenId] >= block.timestamp;
    }
    
    function tokenExpiration(uint tokenId) external view returns (uint){
        return tokenLifespan[tokenId];
    }

    function _getManager() internal virtual returns (address) {}

    modifier onlyManager2() {
        require(msg.sender == _getManager(), "ERR_NOT_MANAGER");
        _;
    }
}
