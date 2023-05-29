import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("SimplePrize", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("CommitRevealPuzzle")
    const contract = await Contract.deploy(ethers.utils.formatBytes32String("100"))
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("CommitRevealPuzzle", function () {
    it("Should function right", async () => {
      const commitment = ethers.utils.formatBytes32String("100")
      const [acc1, acc2, acc3, acc4, acc5, _] = await ethers.getSigners()
      // require not creator
      await expect(contract.guess(commitment)).to.be.revertedWithoutReason()
      await contract.connect(acc2).guess(commitment)
      await contract.connect(acc3).guess(commitment)
      await contract.connect(acc4).guess(commitment)
      
      await expect(contract.connect(acc3).reveal(100)).to
        .be.revertedWithoutReason()
    });
  });
});
