import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("RNGLottery", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("RNGLottery")
    const contract = await Contract.deploy(4, 2)
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("RNGLottery", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      // acc1 buy
      const acc1_cm = await contract.connect(acc1)
        .createCommitment(acc1.address, 1)
      await contract.connect(acc1)
        .buy(acc1_cm, {value: ethers.utils.parseEther("0.01")})

      // acc2 buy
      const acc2_cm = await contract.connect(acc2)
        .createCommitment(acc2.address, 2)
      await contract.connect(acc2)
        .buy(acc2_cm, {value: ethers.utils.parseEther("0.01")})

      // acc3 buy
      const acc3_cm = await contract.connect(acc3)
        .createCommitment(acc3.address, 3)
      await contract.connect(acc3)
        .buy(acc3_cm, {value: ethers.utils.parseEther("0.01")})

      await contract.connect(acc1).reveal(1)
      await contract.connect(acc2).reveal(2)
      await contract.connect(acc3).reveal(3)

      // create some block to fill the gap before drawBlock
      await expect(contract.connect(acc1).withdraw()).to.be.revertedWithoutReason()
      await expect(contract.connect(acc1).withdraw()).to.be.revertedWithoutReason()
      await expect(contract.connect(acc1).withdraw()).to.be.revertedWithoutReason()
      await expect(contract.connect(acc1).withdraw()).to.be.revertedWithoutReason()
      await expect(contract.connect(acc1).withdraw()).to.be.revertedWithoutReason()

      await contract.drawWinner()

      const winner = await contract.winner()
      console.log("winner", winner)
      console.log("winner reward", 
        ethers.utils.formatEther(await ethers.provider.getBalance(winner))
      )
    });
  });
});
