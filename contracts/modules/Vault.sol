// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/INFT.sol";

contract Vault is Ownable {
    event TokenHasDeposit(address depositer, address token, uint tokenId);
    event TokenUnDeposit(address reciver, address token, uint tokenId);

    uint public counter;

    struct DepositToken {
        address depositer;
        string tokenSymbol;
        address tokenAddr;
        uint tokenId;
        uint time;
    }

    mapping(uint => DepositToken) public depositToken;

    // 质押token
    function deposit(address tokenAddr, uint tokenId) external {
        address depositer = _msgSender();
        INFT(tokenAddr).transferFrom(depositer, address(this), tokenId);
        _addToken(depositer, INFT(tokenAddr).symbol(), tokenAddr, tokenId);
        emit TokenHasDeposit(depositer, tokenAddr, tokenId);
    }

    // 赎回token
    function unDeposit(address reciver, uint tokenIndex) external {
        DepositToken memory token = depositToken[tokenIndex];
        require(_checkState(), "ERR_INELIGIBILITY");
        INFT(token.tokenAddr).transferFrom(address(this), reciver, token.tokenId);
        _deleteToken(tokenIndex);
        emit TokenUnDeposit(reciver, token.tokenAddr, token.tokenId);
    }

    // 管理员领取native代币
    function adminClaim(address payable reciver) external payable onlyOwner {
        reciver.transfer(address(this).balance);
    }

    // 管理员领取ERC20代币
    function adminClaim(uint tokenIndex) external onlyOwner {
        DepositToken memory tokenInfo = depositToken[tokenIndex];
        INFT(tokenInfo.tokenAddr).transferFrom(address(this), _msgSender(), tokenInfo.tokenId);
    }

    // internal - 新增token更新数据
    function _addToken(
        address depositer,
        string memory symbol,
        address tokenAddr,
        uint tokenId
    ) internal {
        DepositToken storage tokenInfo = depositToken[counter];
        tokenInfo.depositer = depositer;
        tokenInfo.tokenSymbol = symbol;
        tokenInfo.tokenAddr = tokenAddr;
        tokenInfo.tokenId = tokenId;
        tokenInfo.time = block.timestamp;
        counter++;
    }

    // internal - 删除token销毁数据
    function _deleteToken(uint tokenIndex) internal {
        delete depositToken[tokenIndex];
    }

    // virtual - 检查是否可赎回状态
    function _checkState() internal virtual returns (bool) {}
    
    // virtual - 超级管理员(平台方)
    function _superAdmin() internal virtual returns (address) {}

    modifier onlySuperAdmin() {
        require(_superAdmin() == _msgSender(), "ERR_NOT_AUTH");
        _;
    }

    receive() external payable {}
}
