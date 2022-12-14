// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISlot.sol";

contract Slot is ISlot {
    SlotWhite slotsWhite;

    function addWhiteSlots(uint[] memory _slots) external onlyManager {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool added = slotsWhite.iswWhite[s];
            require(added, "ERR_SLOT_ADDED");

            slotsWhite.slots.push(s);
            slotsWhite.iswWhite[s] = true;

            emit SlotAdd(msg.sender, s);
        }
    }

    function removeWhiteSlots(uint[] memory _slots) external onlyManager {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool added = slotsWhite.iswWhite[s];
            require(!added, "ERR_SLOT_NOT_ADDED");

            slotsWhite.iswWhite[s] = false;

            emit SlotRemove(msg.sender, s);
        }
    }

    function queryAllWhiteSlots() external view returns (uint[] memory) {
        uint counter;

        for (uint i; i < slotsWhite.slots.length; i++) {
            uint s = slotsWhite.slots[i];
            if (slotsWhite.iswWhite[s]) counter++;
        }

        uint[] memory result = new uint[](counter);

        for (uint i; i < slotsWhite.slots.length; i++) {
            uint s = slotsWhite.slots[i];
            if (slotsWhite.iswWhite[s]) result[i] = slotsWhite.slots[i];
        }

        return result;
    }

    function checkSlotWhite(uint _slot) public view returns (bool) {
        return slotsWhite.iswWhite[_slot];
    }

    function getManager() internal virtual returns (address) {}

    modifier onlyManager() {
        require(msg.sender == getManager(), "ERR_NOT_MANAGER");
        _;
    }
}
