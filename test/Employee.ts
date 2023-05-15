import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("Employee", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("Employee")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("Employee", function () {
    it("Should manager employee right", async () => {
      const [acc1, acc2, acc3, _] = await ethers.getSigners()
      await contract.AddEmployee(acc1.address, "acc1", 18, "acc1@123.com",
      "GD", "GZ")
      const [name, age, email, city, state] = await contract.GetAnEmployee(acc1.address)
      expect(name).to.eq("acc1")
      expect(age).to.eq(18)
      expect(email).to.eq("acc1@123.com")
      expect(city).to.eq("GZ")
      expect(state).to.eq("GD")
    });
  });
});
