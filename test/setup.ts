import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import "@nomicfoundation/hardhat-chai-matchers";
import tokenJSON from "../artifacts/contracts/Erc.sol/DDToken.json"

export { loadFixture, ethers, expect, tokenJSON };