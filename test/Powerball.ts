import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("Powerball", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("Powerball")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("Powerball", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      const ticketPrice = ethers.utils.parseEther("0.002")

      await contract.connect(acc1).buy([[1,2,3,4,5,6]], {value: ticketPrice})
      await contract.connect(acc2).buy([[1,2,3,4,5,7]], {value: ticketPrice})
      await contract.connect(acc3).buy([[1,2,3,4,5,8]], {value: ticketPrice})
      await time.increase(86400 * 3)
      await contract.drawNumbers(1)
      await contract.connect(acc1).claim(1)
      const winningNumbers = await contract.winningNumbersFor(1)
      expect(winningNumbers.length).to.eq(6)
      console.log("winning numbers:", winningNumbers)
    });
  });
});
