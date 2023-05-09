import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("AddressValidations", function () {
  let contract: Contract 

  const fixture = async () => {
    const Contract = await ethers.getContractFactory("AddressValidations")
    const contract = await Contract.deploy()
    return contract
  }

  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("ExtractAddress", function () {
    it("Should extract address right", async function () {
      const contract = await loadFixture(fixture)
      expect(await contract.ExtractAddress(
        "0x23ad06b0e032848201fe7dccf69320f381a6de007e7e9a0896f5cf04821cc95f",
        28,
        "0x692beda0e15876f154e6b385842941d404c7447b9729a213ee290027e9d2f757",
        "0x37aba255952ff08dbee9ada64a224076e245c24ea01428f68053d5b42ac9434f"
      )).to.equal("0x1fd60057985434174D44B9098992D397b2cEE491")
    });
  });
});
