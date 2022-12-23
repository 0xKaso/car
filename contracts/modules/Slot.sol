// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/ISlot.sol";

contract Slot is ISlot {
    SlotWhite slotsWhite;

    constructor(){
        slotsWhite.iswWhite[1] = true;
        slotsWhite.slots.push(1);
    }

    // 添加白单插槽
    function addWhiteSlots(uint[] memory _slots) external onlyManagerOnSlot {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool added = slotsWhite.iswWhite[s];
            require(added, "ERR_SLOT_ADDED");

            slotsWhite.slots.push(s);
            slotsWhite.iswWhite[s] = true;

            emit SlotAdd(msg.sender, s);
        }
    }

    // 移除白单插槽
    function removeWhiteSlots(uint[] memory _slots) external onlyManagerOnSlot {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool added = slotsWhite.iswWhite[s];
            require(!added, "ERR_SLOT_NOT_ADDED");

            slotsWhite.iswWhite[s] = false;

            emit SlotRemove(msg.sender, s);
        }
    }

    // 查询所有的白单插槽
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

    // 检查插槽是否是白单
    function checkSlotWhite(uint _slot) public view returns (bool) {
        return slotsWhite.iswWhite[_slot];
    }

    // virtual - 管理员
    // 配置和移除白单插槽用
    function _getManager() internal virtual returns (address) {}

    modifier onlyManagerOnSlot() {
        require(msg.sender == _getManager(), "ERR_NOT_MANAGER");
        _;
    }
}
