import { ethers } from "hardhat";
import { expect } from "chai";
// import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import factory from "./deployer/factory"
import token from "./deployer/token"

describe("deployer", () => {
  it("deploy factory contract", async ()=>{
    const factory_ = await factory()
    console.log(factory_.address)
  })

  it("deploy erc3525 token contract", async ()=>{
    const token_ = await token()
    console.log(token_.address)
  })
});
