import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";
import { BigNumber } from "ethers";

// 3525 token Info
// admin - token id - 1
// user - token id -2
describe("vault module tests", () => {
  let nft,
    nftAddr,
    defaultTokenId = 1;
  let factory, factoryAddr;
  let token3525, token3525Addr;
  let Signers;
  let admin, user;
  const sendValue = BigNumber.from(10).pow(18).mul(1);

  const month = 60 * 60 * 24 * 30;
  const subConfig = {
    price: 10, // 10 wei/month
    period: month, // 1 month
  };

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

  it("add white slot", async () => {
    await token3525
      .connect(Signers[1])
      .addWhiteSlots([2, 3, 4, 5])
      .catch(e => {
        expect(e.message).include("ERR_NOT_MANAGER");
      });
    await token3525.addWhiteSlots([2, 3, 4, 5]);
  });

  it("remove white slot error case", async () => {
    await token3525
      .connect(Signers[1])
      .removeWhiteSlots([3])
      .catch(e => {
        expect(e.message).include("ERR_NOT_MANAGER");
      });

    await token3525.removeWhiteSlots([9]).catch(e => {
      expect(e.message).include("ERR_SLOT_NOT_ADDED");
    });
  });

  it("remove white slot success case", async () => {
    await token3525.removeWhiteSlots([3]);
  });

  it("query all white slot", async () => {
    let whites = await token3525.queryAllWhiteSlots();
    whites = whites.map(v => v.toNumber()).sort();

    expect(whites.toString()).equal([1, 2, 4, 5].toString());
  });

  it("check slot is white", async () => {
    let solt2 = await token3525.checkSlotWhite(2);
    let solt3 = await token3525.checkSlotWhite(3);
    expect(solt2).equal(true);
    expect(solt3).equal(false);
  });
});
