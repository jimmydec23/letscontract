import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("RecurringLottery", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("RecurringLottery")
    const contract = await Contract.deploy(2)
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("RecurringLottery", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      await contract.connect(acc1).buy({value: ethers.utils.parseEther("0.001")})
      // drawBlock not match
      await expect(contract.drawWinner(1)).to.be.revertedWithoutReason()
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.001")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.001")})
      await contract.drawWinner(1)
    });
  });
});
