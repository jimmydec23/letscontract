import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("MyToken", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("MyToken")
    const contract = await Contract.deploy(100)
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("MyToken", function () {
    it("Should set supply, name, symbol right", async () => {
      expect(await contract.totalSupply()).to.equal(100)
      expect(await contract.name()).to.equal("MyToken")
      expect(await contract.symbol()).to.equal("MYT")
      expect(await contract.decimals()).to.equal(18)
    });
    it("Should transfer right", async () => {
      const [acc1, acc2, _] = await ethers.getSigners()
      expect(await contract.balanceOf(acc1.address)).to.equal(100)
      expect(await contract.balanceOf(acc2.address)).to.equal(0)
      await contract.transfer(acc2.address, 10)
      expect(await contract.balanceOf(acc1.address)).to.equal(90)
      expect(await contract.balanceOf(acc2.address)).to.equal(10)
      await expect(contract.transfer(acc2.address, 100)).to.be.reverted
    })
    it("Should transferFrom right", async() => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      await contract.approve(acc2.address, 10)
      expect(await contract.allowance(acc1.address, acc2.address)).to.eq(10)
      await contract.connect(acc2).transferFrom(acc1.address, acc3.address, 10)
      expect(await contract.balanceOf(acc1.address)).to.eq(90)
      expect(await contract.balanceOf(acc3.address)).to.eq(10)
      expect(await contract.allowance(acc1.address, acc2.address)).to.eq(0)
    })
  });
});
