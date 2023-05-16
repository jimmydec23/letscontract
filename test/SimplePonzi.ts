import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("Employee", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("SimplePonzi")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("Employee", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      console.log(
        ethers.utils.formatEther(await ethers.provider.getBalance(acc1.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc2.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc3.address)),
      )

      // injust a function signature into contract
      const hahaFunSig = 'haha() payable'
      const simContract = new ethers.Contract(
        contract.address,
        [...contract.interface.fragments, `function ${hahaFunSig}`],
        acc1,
      )
      await simContract.haha({value: ethers.utils.parseEther("1.0") })
      console.log(
        ethers.utils.formatEther(await ethers.provider.getBalance(acc1.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc2.address)),
        ethers.utils.formatEther(await ethers.provider.getBalance(acc3.address)),
      )
      await expect(
        simContract.haha({value: ethers.utils.parseEther("1.0")})
      ).to.be.revertedWith("require minimum investment")
    });
  });
});
