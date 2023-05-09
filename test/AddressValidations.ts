import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("AddressValidations", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("AddressValidations")
    const contract = await Contract.deploy()
    return contract
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("ExtractAddress", function () {
    it("Should extract address right", async () => {
      expect(await contract.ExtractAddress(
        "0x23ad06b0e032848201fe7dccf69320f381a6de007e7e9a0896f5cf04821cc95f",
        28,
        "0x692beda0e15876f154e6b385842941d404c7447b9729a213ee290027e9d2f757",
        "0x37aba255952ff08dbee9ada64a224076e245c24ea01428f68053d5b42ac9434f"
      )).to.equal("0x1fd60057985434174D44B9098992D397b2cEE491")
    });

    it("Should extract address rigth with sig data", async () => {
      // hash, sig, address from this post: "https://solidity-by-example.org/signature/"
      expect(await contract.ExtractAddressWithSig(
        "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd",
        "0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b"
      )).to.equal("0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd")
    })
  });
});
