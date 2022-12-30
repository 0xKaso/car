import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";
import { BigNumber } from "ethers";

// 3525 token Info
// admin - token id - 1
// user - token id -2
describe("subscription module tests", () => {
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

  it("raise more token", async () => {
    const raiseAmount = 100000;
    await token3525
      .connect(Signers[1])
      .mintValue(raiseAmount)
      .catch(e => {
        expect(e.message).include("Ownable: caller is not the owner");
      });

    const balb = await token3525["balanceOf(uint256)"](1);

    await token3525.mintValue(raiseAmount); //2
    const bala = await token3525["balanceOf(uint256)"](1);

    expect(bala - balb).equal(raiseAmount);
  });

  it("compose single token", async () => {
    const raiseAmount = 100000;
    await token3525.addWhiteSlots([5, 4]);
    await token3525.composeToken([1], 5);
    const bala = await token3525["balanceOf(uint256)"](2);

    expect((raiseAmount + initSupply) / 5).equal(bala);
  });

  it("transfer to get new token", async () => {
    await token3525["transferFrom(uint256,address,uint256)"](1, user, 100);
    await token3525["transferFrom(uint256,address,uint256)"](2, user, 20);
    // user have balance total is 200
  });

  it("compose more token", async () => {
    await token3525.composeToken([3, 4], 4).catch(e => {
      expect(e.message).include("ERR_NOT_TOKEN_OWNER");
    });
    await token3525
      .connect(Signers[1])
      .composeToken([3, 4], 3)
      .catch(e => {
        expect(e.message).include("ERR_NOT_WHITE_SLOT");
      });
    await token3525.connect(Signers[1]).composeToken([3, 4], 4);
    const bal = await token3525["balanceOf(uint256)"](5);
    expect(200 / 4).equal(bal);
  });
});
