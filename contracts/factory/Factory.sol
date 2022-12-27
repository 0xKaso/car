// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Main.sol";
import "../interface/INFT.sol";

contract Factory {
    mapping(address => bool) public isProject;

    struct DepositInfo {
        address proj;
        address who;
        address nft;
        uint tokenId;
    }

    mapping(address => DepositInfo) private projectDepositInfo;

    function getProjctInfo(address proj) external view returns (DepositInfo memory) {
        return projectDepositInfo[proj];
    }

    function create(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address nftAddr,
        uint tokenId
    ) external returns (address) {
        ERC3525Token eRC3525Token = new ERC3525Token();
        address projectAddr = address(eRC3525Token);
        eRC3525Token.init(name_, symbol_, decimals_);

        _deposit(projectAddr, nftAddr, tokenId);

        isProject[projectAddr] = true;
        return projectAddr;
    }

    function _deposit(
        address proj,
        address nftAddr,
        uint tokenId
    ) internal {
        projectDepositInfo[proj].proj = proj;
        projectDepositInfo[proj].who = msg.sender;
        projectDepositInfo[proj].nft = nftAddr;
        projectDepositInfo[proj].tokenId = tokenId;

        INFT(nftAddr).transferFrom(msg.sender, proj, tokenId);
    }
}
