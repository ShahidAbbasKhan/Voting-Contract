
const hre = require("hardhat");

async function main() {
  

  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(["0xdD2FD4581271e230360230F9337D5c0430Bf44C0", "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"]);

  await voting.deployed();

  console.log(
    `Voting Contract deployed to ${voting.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
