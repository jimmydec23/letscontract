import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("GradualPonzi", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("GradualPonzi")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("GradualPonzi", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      console.log(
        ethers.utils.formatEther(await ethers.provider.getBalance(acc1.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc2.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc3.address)),
      )

      await contract.invest({value: ethers.utils.parseEther("1.0") })
      console.log(
        ethers.utils.formatEther(await ethers.provider.getBalance(acc1.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc2.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc3.address)),
      )
      await expect(
        contract.invest({value: ethers.utils.parseEther("0.00001")})
      ).to.be.revertedWith("require minimum investment")
    });
  });
});
