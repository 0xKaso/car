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

  it("not owner can not transfer owner", async () => {
    await token3525
      .connect(Signers[1])
      .transferOwnership(admin)
      .catch(e => {
        expect(e.message).to.include("caller is not the owner");
      });
  });

  it("owner can transfer owner", async () => {
    await token3525.transferOwnership(user);
    const newOwner = await token3525.owner();
    expect(newOwner).to.equal(user);
  });

  it("owner can renounce Ownership", async () => {
    await token3525.connect(Signers[1]).renounceOwnership();
  });
});
