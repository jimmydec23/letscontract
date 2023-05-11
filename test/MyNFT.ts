import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("MyNFT", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("MyNFT")
    const contract = await Contract.deploy("MyNFT", "MFT")
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("MyNFT", function () {
    it("Should mint an NFT right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      expect(await contract.name()).to.equal("MyNFT")
      expect(await contract.symbol()).to.equal("MFT")
      await contract.mint(acc1.address, 1)
      expect(await contract.ownerOf(1)).to.equal(acc1.address)
      expect(await contract.balanceOf(acc1.address)).to.equal(1)
      expect(await contract.balanceOf(acc2.address)).to.equal(0)
      await contract.transferFrom(acc1.address, acc3.address, 1)
      expect(await contract.balanceOf(acc1.address)).to.equal(0)
      expect(await contract.balanceOf(acc3.address)).to.equal(1)
      expect(await contract.ownerOf(1)).to.equal(acc3.address)
    });
  });
});
