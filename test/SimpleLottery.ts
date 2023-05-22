import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("SimpleLottery", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("SimpleLottery")
    const contract = await Contract.deploy(1 * 3600)
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("SimpleLottery", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      await contract.connect(acc1).buy({value: ethers.utils.parseEther("0.01")})
      await contract.connect(acc2).buy({value: ethers.utils.parseEther("0.01")})
      await contract.connect(acc3).buy({value: ethers.utils.parseEther("0.01")})
      await time.increase(5*3600)
      await contract.drawWinner()
      const winner = await contract.winner()
      console.log(
        "Winner:", winner,
        "Is winner acc1?", winner == acc1.address,
        "Is winner acc2?", winner == acc2.address,
        "Is winner acc3?", winner == acc3.address,
        )
    });
  });
});
