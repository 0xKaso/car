// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./@solvprotocol/erc-3525/ERC3525.sol";

import "./modules/Vault.sol";
import "./modules/Slot.sol";
import "./modules/Subscription.sol";

contract ERC3525Token is Context, ERC3525, Vault, Slot, Subscription {
    bool hasInit;

    function init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external {
        require(hasInit == false, "ERR_HAS_INITED");
        _ERC3525_init(name_, symbol_, decimals_);
        hasInit = true;
    }

    function mint(
        address mintTo_,
        uint tokenId_,
        uint slot_,
        uint value_
    ) public virtual {
        ERC3525._mint(mintTo_, tokenId_, slot_, value_);
    }

    function mintValue(uint tokenId_, uint value_) public virtual {
        ERC3525._mintValue(tokenId_, value_);
    }

    function _checkTokenStateOfOwner(uint tokenId) internal view returns (bool) {
        if (_hasExpired(tokenId)) return true; // skip
        return _ownerOf(tokenId) == msg.sender ? true : false;
    }

    function _checkState() internal view override returns (bool state) {
        uint total = supply();
        state = true;
        for (uint i; i < total; i++) {
            if (_checkTokenStateOfOwner(i)) {
                continue;
            } else {
                state = false;
                break;
            }
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
}
