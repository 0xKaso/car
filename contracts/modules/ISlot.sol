// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISlot {
    struct SlotWhite {
        uint[] slots;
        mapping(uint => bool) iswWhite;
    }

    event SlotAdd(address indexed caller, uint indexed slot);
    event SlotRemove(address indexed caller, uint indexed slot);
}
