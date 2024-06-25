import { BaseContract } from "ethers";
import { loadFixture, ethers, expect, tokenJSON } from "./setup"

describe("MShop", function(){
    async function deploy() {
        const [owner, seller, buyer] = await ethers.getSigners();
        const Factory = await ethers.getContractFactory("MShop", owner);
        const payments = await Factory.deploy();
        await payments.waitForDeployment();

        const erc20 = new ethers.Contract(await payments.token(), tokenJSON.abi, owner)

        return { owner, seller, buyer, payments, erc20}
    }

    it("should have an owner and a token", async function(){
        const { owner, seller, buyer, payments } = await loadFixture(deploy);
        expect(await payments.owner()).to.eq(owner.address);
        expect(await payments.token()).to.be.properAddress
    })

    it("allows to buy", async function() {
        const { owner, seller, buyer, payments, erc20 } = await loadFixture(deploy);
        const tokenAmount = 3;
        const txData = {
            value: tokenAmount,
            to: payments.getAddress()
        }

        const tx = await buyer.sendTransaction(txData)
        await tx.wait
        expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)
        await expect(tx).to.changeEtherBalance(payments, tokenAmount)
        await expect(tx).to.emit(payments, "Bought").withArgs(tokenAmount, buyer.address)
    })

    it("allows to sell", async function(){
        const { owner, seller, buyer, payments, erc20 } = await loadFixture(deploy);
        const tokenAmount = 3;
        const txData = {
            value: tokenAmount,
            to: payments.getAddress()
        }

        const tx = await owner.sendTransaction(txData)
        await tx.wait
        expect(await erc20.balanceOf(owner.address)).to.eq(tokenAmount);

        const sellAmount = 2;
        const txApprove = await erc20.approve(payments.getAddress(), sellAmount);
        expect(txApprove).to.emit(erc20, "Approve").withArgs(owner.address, payments.getAddress(), sellAmount)

        const txSell = await payments.sell(sellAmount)
        expect(txSell).to.changeEtherBalance(owner.address, sellAmount)
        expect(txSell).to.emit(payments, "Sold").withArgs(sellAmount, owner.address)
    })
})