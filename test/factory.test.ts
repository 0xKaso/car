import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory";
import NFT from "./deployer/nft";

describe("factory", () => {
  let nft: any;

  it("deploy mock nft", async () => {
    nft = await NFT();
    console.log(nft.address);
  });

  it("create erc 3525 token", async () => {
    const factory = await Factory();

    await nft.setApprovalForAll(factory.address, true);

    const tokenAddr = await factory.callStatic.create("Kaso", "KS", 0, nft.address, 1);
    await factory.create("Kaso", "KS", 0, nft.address, 1);

    const tokenInfo = await factory.getProjctInfo(tokenAddr);

    expect(tokenInfo.proj).to.equal(tokenAddr)
    expect(tokenInfo.nft).to.equal(nft.address)
    expect(tokenInfo.tokenId).to.equal(1)

    console.log(tokenInfo);
  });
});
