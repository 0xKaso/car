import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";
import { BigNumber } from "ethers";

describe("owner module tests", () => {
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
    console.log("debug0");
    nft = await NFT();
    factory = await Factory();
    console.log("debug0-1");
    nftAddr = nft.address;
    factoryAddr = factory.address;

    console.log("debug0-2");
    Signers = await ethers.getSigners();
    console.log("debug0-3");
    admin = Signers[0].address;
    console.log("debug0-4", admin);
    try {
      user = Signers[1].address;
    } catch (error) {
      console.log(error);
    }

    console.log("debug1");
    await nft.setApprovalForAll(factoryAddr, true);

    token3525Addr = await factory.callStatic.create("Azuki CN", "Azuki", nftAddr, defaultTokenId, initSupply, admin);
    await factory.create("Azuki CN", "Azuki", nftAddr, defaultTokenId, initSupply, admin);
    console.log("debug2");
    token3525 = await ethers.getContractAt("ERC3525Token", token3525Addr);
    console.log("debug3");
    await nft.setApprovalForAll(token3525Addr, true);
  });

  it("not owner can not transfer owner", async () => {
    await token3525
      .connect(Signers[1])
      .transferOwnership(admin)
      .catch(e => {
        expect(e.message).include("caller is not the owner");
      });
  });

  it("owner can transfer owner", async () => {
    await token3525.transferOwnership(user);
    const newOwner = await token3525.owner();
    expect(newOwner).equal(user);
  });

  it("owner can renounce Ownership", async () => {
    await token3525.connect(Signers[1]).renounceOwnership();
  });
});
