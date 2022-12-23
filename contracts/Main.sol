// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@solvprotocol/erc-3525/ERC3525.sol";

import "./modules/Vault.sol";
import "./modules/Slot.sol";
import "./modules/Subscription.sol";

contract ERC3525Mintable is Context, ERC3525, Vault, Slot, Subscription {
    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC3525(name_, symbol_, decimals_) {}

    function composeOrSplitToken(uint fromTokenId_, uint slot_, uint amount_) external returns (uint) {
        uint fromSlot = this.slotOf(fromTokenId_);

        require(checkSlotWhite(slot_) && slot_ != 0, "ERR_NOT_WHITE_SLOT");

        uint burnFromTokenAmount = amount_;
        uint burnTokenBalance = this.balanceOf(fromTokenId_);
        uint getToTokenAmount = (fromSlot * amount_) / slot_;

        uint256 newTokenId = _mint(msg.sender, slot_, getToTokenAmount);

        burnTokenBalance == burnFromTokenAmount
            ? _burn(fromTokenId_)
            : _burnValue(fromTokenId_, burnFromTokenAmount);

        // _updateReward(fromTokenId_, newTokenId, burnFromTokenAmount);

        return newTokenId;
    }

    function mint(address mintTo_, uint256 tokenId_, uint256 slot_, uint256 value_) public virtual {
        ERC3525._mint(mintTo_, tokenId_, slot_, value_);
    }

    function mintValue(uint256 tokenId_, uint256 value_) public virtual {
        ERC3525._mintValue(tokenId_, value_);
    }

    function _checkTokenStateOfOwner(uint tokenId) internal view returns(bool){
        if(_hasExpired(tokenId)) return true; // skip
        return _ownerOf(tokenId) == msg.sender? true: false;
    }  

    function _checkState() internal view override returns(bool state){
        uint t = 1000000;
        state = true;
        for(uint i; i < t; i++){
            if(_checkTokenStateOfOwner(t)){
                continue;
            } else {
                state = false;
                break;
            }
        }
    }

    // Subscription, Slot
   function _getManager() internal override(Subscription,Slot) view returns (address) {
        return owner();
   }

    // Subscription
    function _ownerOf(uint tokenId) internal view override returns (address) {
        return this.ownerOf(tokenId);
    }
    
}
