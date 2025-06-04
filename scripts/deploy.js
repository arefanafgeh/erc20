const hre = require("hardhat");

async function main() {
  const Contract = await hre.ethers.getContractFactory("MyToken"); // Replace with your contract name
  const contract = await Contract.deploy(1000000000);
  
  await contract.waitForDeployment();
  console.log("Contract deployed at:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});