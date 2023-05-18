import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import { Contract } from "ethers"
import { ethers } from "hardhat"

describe("SimplePyramid", function () {
  let contract: Contract 

  // deploy contract
  const fixture = async () => {
    const Contract = await ethers.getContractFactory("SimplePyramid")
    const contract = await Contract.deploy({value: ethers.utils.parseEther("1.0")})
    return contract
  }

  const showBalance = async (msg:string) => {
      const [acc1, acc2, acc3, acc4, _] = await ethers.getSigners()
      console.log("\t%s", msg)
      console.log(
        "\tbalance: %d\t%d\t%d\t%d",
        ethers.utils.formatEther(await contract.balanceOf(acc1.address)),
        ethers.utils.formatEther(await contract.balanceOf(acc2.address)),
        ethers.utils.formatEther(await contract.balanceOf(acc3.address)),
        ethers.utils.formatEther(await contract.balanceOf(acc4.address)),
      )
  }

  // deploy contract before each test
  beforeEach('deploy contract', async() => {
    contract = await loadFixture(fixture)
  })

  describe("SimplePyramid", function () {
    it("Should function right", async () => {
      await showBalance("At acc1 init and invest:")
      const [acc1, acc2, acc3, acc4, acc5, acc6, acc7, _] = await ethers.getSigners()

      /*
      await contract.invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc1 invect")
      */

      await expect(
        contract.invest({value: ethers.utils.parseEther("0.00001")})
      ).to.be.revertedWith("require minimum investment")

      await contract.connect(acc2)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc2 invest")

      await contract.connect(acc3)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc3 invest")

      await contract.connect(acc4)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc4 invest")

      await contract.connect(acc5)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc5 invest")

      await contract.connect(acc6)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc6 invest")

      await contract.connect(acc7)
        .invest({value: ethers.utils.parseEther("1.0") })
      await showBalance("After acc7 invest")
    });
  });
});
