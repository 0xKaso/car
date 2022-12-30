// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/ISlot.sol";

contract Slot is ISlot {
    uint[] slots;
    mapping(uint => bool) iswWhite;

    constructor() {
        iswWhite[1] = true;
        slots.push(1);
    }

    // 添加白单插槽
    function addWhiteSlots(uint[] memory _slots) external onlyManagerOnSlot {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool isAdded = iswWhite[s];
            require(isAdded == false, "ERR_SLOT_ADDED");

            slots.push(s);
            iswWhite[s] = true;

            emit SlotAdd(msg.sender, s);
        }
    }

    // 移除白单插槽
    function removeWhiteSlots(uint[] memory _slots) external onlyManagerOnSlot {
        for (uint i; i < _slots.length; i++) {
            uint s = _slots[i];
            bool added = iswWhite[s];
            require(added == true, "ERR_SLOT_NOT_ADDED");

            iswWhite[s] = false;

            emit SlotRemove(msg.sender, s);
        }
    }

    // 查询所有的白单插槽
    function queryAllWhiteSlots() external view returns (uint[] memory) {
        uint counter;

        for (uint i; i < slots.length; i++) {
            uint s = slots[i];
            if (iswWhite[s]) {
                counter++;
            }
        }

        uint[] memory result = new uint[](counter);
        for (uint j; j < slots.length; j++) {
            uint s = slots[j];
            if (iswWhite[s]) {
                result[counter - 1] = slots[j];
                counter--;
            }
        }

        return result;
    }

    // 检查插槽是否是白单
    function checkSlotWhite(uint _slot) public view returns (bool) {
        return iswWhite[_slot];
    }

    // virtual - 管理员
    // 配置和移除白单插槽用
    function _getManager() internal virtual returns (address) {}

    modifier onlyManagerOnSlot() {
        require(msg.sender == _getManager(), "ERR_NOT_MANAGER");
        _;
    }
}
