import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("SimplePrize", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("SimplePrize")
    const contract = await Contract.deploy(ethers.utils.formatBytes32String("100"))
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("SimplePrize", function () {
    it("Should function right", async () => {
      await expect(contract.guess(10)).to.be.revertedWithoutReason()
    });
  });
});
