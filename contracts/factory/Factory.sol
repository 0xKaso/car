// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Main.sol";

contract Factpry {
    mapping (address => bool) public isProject;

    function create(string memory name_,string memory symbol_,uint8 decimals_) external returns(address){
        ERC3525Token eRC3525Token = new ERC3525Token();
        eRC3525Token.init(name_, symbol_,decimals_);
        isProject[address(eRC3525Token)] = true;

        return address(eRC3525Token);
    }
}
