import { ethers } from "hardhat";

async function main() {
    const token = await ethers.getContractFactory("ERC3525Token")
    const tokenInstance = await token.deploy()
    await tokenInstance.deployed()
    
    return tokenInstance
}

export default main;