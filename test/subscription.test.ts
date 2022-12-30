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

  it("set subscription", async () => {
    await token3525
      .connect(Signers[1])
      .setSubConfig(subConfig)
      .catch(e => {
        expect(e.message).to.include("ERR_NOT_MANAGER");
      });
    await token3525.setSubConfig(subConfig);
  });

  it("buy token", async () => {
    await token3525["transferFrom(uint256,address,uint256)"](1, user, 1);
  });

  it("subscript should have enough eth", async () => {
    await token3525.extendTokenSubscription(1, 1).catch(e => {
      expect(e.message).to.include("ERR_ETHER_NOT_ENOUGH");
    });
  });

  it("extend subscription token 1 month and pay 10 wei eth", async () => {
    await token3525.extendTokenSubscription(1, 1, { value: 10 });
    const time = await token3525.tokenExpiration(1);
    const now = new Date();
    const data = time - now.getTime() / 1000;
    expect(Math.floor(data / month)).to.equal(1);
  });

  it("extend subscription token 12 month and pay 120 wei eth", async () => {
    await token3525.connect(Signers[1]).extendTokenSubscription(2, 12, { value: 120 });
    const time = await token3525.tokenExpiration(2);
    const now = new Date();
    const data = time - now.getTime() / 1000;
    expect(Math.floor(data / month)).to.equal(12);
  });

  it("revoke token who is token owner", async () => {
    await token3525.revokeTokenSubscription(2).catch(e => {
      expect(e.message).to.include("NOT_TOKEN_OWNER");
    });
  });

  it("revoke token who is token owner", async () => {
    await token3525.connect(Signers[1]).revokeTokenSubscription(2);
  });

  it("query token is expired", async () => {
    const isExpired1 = await token3525.hasExpired(1);
    const isExpired2 = await token3525.hasExpired(2);
    expect(isExpired1).to.equal(false);
    expect(isExpired2).to.equal(true);
  });

  it("revoke all token subscription", async () => {
    await token3525.connect(Signers[0]).revokeTokenSubscription(1);
  });

  it("x[1/3] user and admin not expired ", async () => {
    await token3525.extendTokenSubscription(1, 12, { value: 120 });
    await token3525.connect(Signers[1]).extendTokenSubscription(2, 12, { value: 120 });

    await token3525.unDeposit(admin, 0).catch(e => {
      expect(e.message).include("ERR_NON_CONFORMANCE");
    });
  });

  it("✓[2/3] user expired but admin not expired", async () => {
    await token3525.connect(Signers[1]).revokeTokenSubscription(2);
    await token3525.unDeposit(admin, 0);
  });

  it("x[3/3] user not expired but admin expired", async () => {
    await token3525.connect(Signers[1]).extendTokenSubscription(2, 12, { value: 120 });
    await token3525.revokeTokenSubscription(1);

    await token3525.deposit(nftAddr, 2);
    await token3525.unDeposit(admin, 1).catch(e => {
      expect(e.message).include("ERR_NON_CONFORMANCE");
    });
  });
});
