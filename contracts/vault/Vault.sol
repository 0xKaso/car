// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC721.sol";

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

    mapping (uint => DepositToken) public depositToken;

    function deposit(address tokenAddr, uint tokenId) external {
        address depositer = _msgSender();
        IERC721(tokenAddr).transferFrom(depositer,address(this),tokenId);
        _addToken(depositer, IERC721(tokenAddr).symbol(), tokenAddr, tokenId);
        emit TokenHasDeposit(depositer, tokenAddr, tokenId);
    }

    function unDeposit(address reciver, uint tokenIndex) external {
        DepositToken memory token = depositToken[tokenIndex];
        require(_checkState(),"ERR_INELIGIBILITY");
        IERC721(token.tokenAddr).transferFrom(address(this), reciver, token.tokenId);
        _deleteToken(tokenIndex);
        emit TokenUnDeposit(reciver, token.tokenAddr, token.tokenId);
    }

    function adminClaim(address payable reciver) external payable onlyOwner {
        reciver.transfer(address(this).balance);
    }

    function adminClaim(uint tokenIndex) external onlyOwner {
        DepositToken memory tokenInfo = depositToken[tokenIndex];
        IERC721(tokenInfo.tokenAddr).transferFrom(address(this), _msgSender() ,tokenInfo.tokenId);
    }

    function _addToken(address depositer, string memory symbol, address tokenAddr, uint tokenId) internal {
        DepositToken storage tokenInfo = depositToken[counter];
        tokenInfo.depositer = depositer;
        tokenInfo.tokenSymbol = symbol;
        tokenInfo.tokenAddr = tokenAddr;
        tokenInfo.tokenId = tokenId;
        tokenInfo.time = block.timestamp;
        counter++;
    }

    function _deleteToken(uint tokenIndex) internal {
        delete depositToken[tokenIndex];
    }

    function _checkState() internal virtual  returns (bool) { }
    function _superAdmin() internal virtual  returns (address) { }

    modifier superAdmin() {
        require(_superAdmin() == _msgSender(),"ERR_NOT_AUTH");
        _;
    }

    receive() external payable {}
}
