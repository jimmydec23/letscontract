import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("PredictionMarket", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("PredictionMarket")
    const contract = await Contract.deploy(
        5, {value: ethers.utils.parseEther("0.001")}
    )
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("PredictionMarket", function () {
    it("Should function right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      await contract.connect(acc1).orderSell(80, 100)
      await contract.connect(acc1).orderSell(80, 200)
      const trade1 = 1;
      await contract.connect(acc2)
        .tradeBuy(1, {value: ethers.utils.parseEther("0.0000000000000001")})

      await contract.fund( {value: ethers.utils.parseEther("0.01")})
      await contract.fund( {value: ethers.utils.parseEther("0.01")})
      await contract.fund( {value: ethers.utils.parseEther("0.01")})
      
      await contract.resolve(true)
    });
  });
});
