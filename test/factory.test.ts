import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";

describe("factory", () => {
  let nft;
  let nftAddr;
  let Signers;
  let admin;

  before(async () => {
    Signers = await ethers.getSigners();
    nft = await NFT();
    nftAddr = nft.address;
  });

  it("create erc 3525 token", async () => {
    const factory = await Factory();
    const initSupply = 100000000;
    const initReceiver = Signers[0].address;

    await nft.setApprovalForAll(factory.address, true);

    const tokenAddr = await factory.callStatic.create("Azuki CN", "Azuki", nft.address, 1, initSupply, initReceiver);
    await factory.create("Azuki CN", "Azuki", nft.address, 1, initSupply, initReceiver);

    const token = await factory.getProjectInfo(tokenAddr);
    const Token = await ethers.getContractAt("ERC3525Token", tokenAddr);

    const bal = await Token["balanceOf(uint256)"](1);

    expect(token.proj).to.equal(tokenAddr);
    expect(token.nft).to.equal(nft.address);
    expect(token.tokenId).to.equal(1);
    expect(bal).to.equal(initSupply);
  });
});
