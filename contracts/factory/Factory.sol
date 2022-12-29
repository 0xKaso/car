// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../Main.sol";
import "../interface/INFT.sol";
import "../modules/Ownable.sol";

contract Factory is Ownable {
    struct DepositInfo {
        address proj;
        address who;
        address nft;
        uint tokenId;
    }

    mapping(address => bool) public isProject;
    mapping(address => DepositInfo) private projectDepositInfo;

    function getProjectInfo(address proj) external view returns (DepositInfo memory) {
        return projectDepositInfo[proj];
    }

    function create(string memory name_, string memory symbol_, address nftAddr, uint tokenId, uint supply, address receiver) external returns (address) {
        ERC3525Token eRC3525Token = new ERC3525Token();
        address projectAddr = address(eRC3525Token);

        eRC3525Token.init(address(this), name_, symbol_, supply, receiver);
        _deposit(projectAddr, nftAddr, tokenId);
        eRC3525Token.NFT_init(nftAddr, tokenId);

        isProject[projectAddr] = true;
        return projectAddr;
    }

    function _deposit(address proj, address nftAddr, uint tokenId) internal {
        projectDepositInfo[proj].proj = proj;
        projectDepositInfo[proj].who = msg.sender;
        projectDepositInfo[proj].nft = nftAddr;
        projectDepositInfo[proj].tokenId = tokenId;

        INFT(nftAddr).transferFrom(msg.sender, proj, tokenId);
    }
}
