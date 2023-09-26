async function main() {
  const HelloWorld = await ethers.getContractFactory("UniswapV3Twap");
  const hello_world = await HelloWorld.deploy(10, 10);
  console.log("Contract Deployed to Address:", hello_world.address);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });