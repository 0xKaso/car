import { ethers } from "hardhat";
import { expect } from "chai";
import Factory from "./deployer/factory"
import Token from "./deployer/token"
import NFT from "./deployer/nft"

describe("deployer", () => {
  let nft

  it("deploy mock nft", async()=>{
    nft = await NFT()
    console.log(nft.address)
  })

  it("deploy factory contract", async ()=>{
    const factory_ = await Factory()
    console.log(factory_.address)
  })

  it("deploy erc3525 token contract", async ()=>{
    const token_ = await Token()
    console.log(token_.address)
  })

  
});
