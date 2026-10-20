const hre = require("hardhat");
async function main() {
  const AuctionData = await hre.ethers.getContractFactory("ApexAuction");
  const apexAuction = await AuctionData.deploy();
  await apexAuction.deployed();
  console.log("-> ApexAuction Engine live at:", apexAuction.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
