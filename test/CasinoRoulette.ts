import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("CasinoRoulette", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("CasinoRoulette")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("CasinoRoulette", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()

      await contract.connect(acc1)
        .wager(0, 0, {value: ethers.utils.parseEther("1")})
      const bet1 = await contract.counter()

      await contract.connect(acc2)
        .wager(1, 30, {value: ethers.utils.parseEther("1")})
      const bet2 = await contract.counter()

      await contract.connect(acc3)
        .wager(1, 5, {value: ethers.utils.parseEther("1")})
      const bet3 = await contract.counter()

      // add some funds
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})
      await contract.fund({value: ethers.utils.parseEther("1")})

      console.log("bet ids:", bet1, bet2, bet3)

      await contract.connect(acc1).spin(bet1)
      await contract.connect(acc2).spin(bet2)
      await contract.connect(acc3).spin(bet3)
    });
  });
});
