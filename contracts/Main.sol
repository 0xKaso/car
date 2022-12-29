// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./@solvprotocol/erc-3525/ERC3525.sol";

import "./modules/Vault.sol";
import "./modules/Slot.sol";
import "./modules/Subscription.sol";

interface IFactory {
    function owner() external view returns (address);
}

contract ERC3525Token is ERC3525, Vault, Slot, Subscription {
    bool hasInit;
    uint initSupply;

    IFactory factory;

    function init(address factory_, string memory name_, string memory symbol_, uint supply_, address admin) external {
        require(hasInit == false, "ERR_HAS_INITED");
        _ERC3525_init(name_, symbol_, 0);
        initSupply = supply_;
        hasInit = true;
        factory = IFactory(factory_);
        _transferOwnership(admin);
    }

    function mintValue(uint tokenId_, uint value_) public virtual {
        ERC3525._mintValue(tokenId_, value_);
    }

    function _checkTokenStateOfOwner(uint tokenId) internal view returns (bool) {
        // if (_hasExpired(tokenId)) return true; // skip
        return _ownerOf(tokenId) == msg.sender ? true : false;
    }

    function _checkState() internal view override {
        uint total = supply();
        for (uint i = 1; i < total; i++) {
            bool _notOwnerAndNotExpired = _ownerOf(i) != _msgSender() && _hasExpired(i) == false;
            if (_notOwnerAndNotExpired) revert();
        }
    }

    // Subscription, Slot
    function _getManager() internal view override(Subscription, Slot) returns (address) {
        return owner();
    }

    // Subscription
    function _ownerOf(uint tokenId) internal view override returns (address) {
        return this.ownerOf(tokenId);
    }

    // vault
    function _superAdmin() internal view override returns (address) {
        return factory.owner();
    }

    // vault
    function _after_NFT_init() internal override {
        ERC3525._mint(owner(), 1, initSupply);
    }
}
