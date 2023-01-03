// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Giant Cat", "GC") {
        _tokenIds.increment();
        mint(msg.sender);
        mint(msg.sender);
        mint(msg.sender);
        mint(msg.sender);
        mint(msg.sender);
    }

    function mint(address player) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);

        _tokenIds.increment();
        return newItemId;
    }
}
