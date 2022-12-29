import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory"
import Token from "./deployer/token"
import NFT from "./deployer/nft"

describe("deployer", () => {
  let nft

  it("deploy mock nft", async()=>{
    nft = await NFT()
  })

  it("deploy factory contract", async ()=>{
    const factory_ = await Factory()
  })

  it("deploy erc3525 token contract", async ()=>{
    const token_ = await Token()
  })
});
