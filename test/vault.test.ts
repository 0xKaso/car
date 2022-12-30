import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";
import { BigNumber } from "ethers";

describe("vault module tests", () => {
  let nft,
    nftAddr,
    defaultTokenId = 1;
  let factory, factoryAddr;
  let token3525, token3525Addr;
  let Signers;
  let admin, user;
  const sendValue = BigNumber.from(10).pow(18).mul(1);

  const initSupply = 100000000;

  before(async () => {
    nft = await NFT();
    factory = await Factory();

    nftAddr = nft.address;
    factoryAddr = factory.address;

    Signers = await ethers.getSigners();
    admin = Signers[0].address;
    user = Signers[1].address;

    await nft.setApprovalForAll(factoryAddr, true);

    token3525Addr = await factory.callStatic.create("Azuki CN", "Azuki", nftAddr, defaultTokenId, initSupply, admin);
    await factory.create("Azuki CN", "Azuki", nftAddr, defaultTokenId, initSupply, admin);

    token3525 = await ethers.getContractAt("ERC3525Token", token3525Addr);

    await nft.setApprovalForAll(token3525Addr, true);
  });

  it("deposit nft and check deposit new token information", async () => {
    const infoId = await token3525.callStatic.deposit(nftAddr, 2);
    await token3525.deposit(nftAddr, 2);
    const bal = await nft.balanceOf(token3525Addr);
    const depositInfo = await token3525.depositToken(infoId);

    expect(bal).equal(2);
    expect(depositInfo.depositer).equal(admin);
    expect(depositInfo.tokenId).equal(2);
    expect(depositInfo.tokenAddr).equal(nftAddr);
  });

  it("send native token to contract", async () => {
    await Signers[0].sendTransaction({
      to: token3525Addr,
      value: sendValue,
    });

    const b3525 = await ethers.provider.getBalance(token3525Addr);
    expect(b3525).equal(sendValue);
  });

  it("manager claim native token", async () => {
    await token3525
      .connect(Signers[1])
      .adminClaim(admin)
      .catch(e => {
        expect(e.message).include("caller is not the owner");
      });

    await token3525.adminClaim(admin);
    const b3525 = await ethers.provider.getBalance(token3525Addr);
    expect(b3525).equal(0);
  });

  it("super admin can withdrew token", async () => {
    await token3525.adminClaimERC721(0);
  });
});
