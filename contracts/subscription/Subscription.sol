// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Subscription {
    struct SubConfig {
        uint price;
        uint period;
    }

    event SubscribeTokenUpdate(address caller, uint tokenId, uint expiration);

    SubConfig subConfig;
    mapping(uint => uint) tokenLifespan;

    // 配置订阅讯息
    function setSubConfig(SubConfig memory subConfig_) external onlyManagerOnSub {
        subConfig = subConfig_;
    }

    // 延长token过期时间
    function extendTokenSubscription(uint tokenId, uint times) external payable {
        uint payAmount = times * subConfig.price;
        uint extendTime = times * subConfig.period;

        require(msg.value >= payAmount, "ERR_ETHER_NOT_ENOUGH");

        tokenLifespan[tokenId] == 0 ? tokenLifespan[tokenId] = block.timestamp + extendTime : tokenLifespan[tokenId] += extendTime;

        emit SubscribeTokenUpdate(msg.sender, tokenId, tokenLifespan[tokenId]);
    }

    // 销毁token过期时间 
    function revokeTokenSubscription(uint tokenId) external {
        delete tokenLifespan[tokenId];
        emit SubscribeTokenUpdate(msg.sender, tokenId, tokenLifespan[tokenId]);
    }

    // token是否过期
    function hasExpired(uint tokenId) external view returns (bool) {
        return tokenLifespan[tokenId] >= block.timestamp;
    }

    // token过期时间
    function tokenExpiration(uint tokenId) external view returns (uint) {
        return tokenLifespan[tokenId];
    }

    // virtual - 管理员
    // 用来配置单次订阅周期和价格
    function _getManager() internal virtual returns (address) {}

    // 仅管理员
    modifier onlyManagerOnSub() {
        require(msg.sender == _getManager(), "ERR_NOT_MANAGER");
        _;
    }
}
