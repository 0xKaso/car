import { ethers } from "hardhat";

async function main() {
    const nft = await ethers.getContractFactory("NFT")
    const nftInstance = await nft.deploy()
    await nftInstance.deployed()
    
    return nftInstance
}

export default main;