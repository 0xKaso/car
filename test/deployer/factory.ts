import { ethers } from "hardhat";

async function main() {
    const factory = await ethers.getContractFactory("Factory")
    const factoryInstance = await factory.deploy()
    await factoryInstance.deployed()
    
    return factoryInstance
}

export default main;