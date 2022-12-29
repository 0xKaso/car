import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";

describe("factory", () => {
  let nft, nftAddr;
  let factory , factoryAddr;
  let token3525,token3525Addr;
  let Signers;
  let admin;

  const initSupply = 100000000;

  before(async () => {
    nft = await NFT();
    factory = await Factory();

    nftAddr = nft.address;
    factoryAddr = factory.address

    Signers = await ethers.getSigners();
    admin = Signers[0].address;

    await nft.setApprovalForAll(factory.address, true);

    token3525Addr = await factory.callStatic.create("Azuki CN", "Azuki", nft.address, 1, initSupply, admin);
    await factory.create("Azuki CN", "Azuki", nft.address, 1, initSupply, admin);

    token3525 = await ethers.getContractAt("ERC3525Token", token3525Addr);
  });
});
