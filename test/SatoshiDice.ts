import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("SatoshiDice", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("SatoshiDice")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("SimpleLottery", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()

      await contract.connect(acc1)
        .wager(100, {value: ethers.utils.parseEther("1")})
      const bet1 = await contract.counter()

      await contract.connect(acc2)
        .wager(300, {value: ethers.utils.parseEther("1")})
      const bet2 = await contract.counter()

      await contract.connect(acc3)
        .wager(500, {value: ethers.utils.parseEther("1")})
      const bet3 = await contract.counter()

      // add some funds
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})

      console.log("bet ids:", bet1, bet2, bet3)

      await contract.connect(acc1).roll(bet1)
      await contract.connect(acc2).roll(bet2)
      await contract.connect(acc3).roll(bet3)
    });
  });
});
