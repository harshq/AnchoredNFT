import {
  ethers,
  JsonRpcProvider,
  BigNumberish,
  keccak256,
  randomBytes,
} from "ethers";
import {
  VRF_COORDINATOR_ADDRESS,
  NFT_ADDRESS,
  DEFAULT_ANVIL_PRIVATE_KEY,
} from "./config.js";

import VRFCoordinatorABI from "abi/VRFCoordinatorV2_5Mock" with { type: "json" };
import PlanetNFTABI from "abi/PlanetNFT" with { type: "json" };

async function main() {
  const provider = new JsonRpcProvider("http://localhost:8545");
  const wallet = new ethers.Wallet(DEFAULT_ANVIL_PRIVATE_KEY, provider);

  const vrf = new ethers.Contract(
    VRF_COORDINATOR_ADDRESS,
    VRFCoordinatorABI,
    wallet
  );

  const nft = new ethers.Contract(NFT_ADDRESS, PlanetNFTABI, wallet);

  console.log("👀 Listening for contract events");
  nft.on("PlanetRequested", async (requestId: BigNumberish, minter: string) => {
    console.log(
      `📡 PlanetRequested: Detected request #${requestId.toString()} from ${minter}`
    );

    const rand1 = BigInt(keccak256(randomBytes(32)));
    const rand2 = BigInt(keccak256(randomBytes(32)));
    try {
      const tx = await vrf.fulfillRandomWordsWithOverride(
        requestId,
        NFT_ADDRESS,
        [rand1, rand2]
      );
      await tx.wait();
      console.log(
        `📡 PlanetRequested: Fulfilled ${requestId} with ${rand1.toString()} | ${rand1.toString()}`
      );
    } catch (err) {
      console.error("📡 PlanetRequested: Fulfillment failed:", err);
    }
  });

  nft.on(
    "PlanetMinted",
    async (requestId: BigNumberish, minter: string, tokenId: BigNumberish) => {
      console.log(`⚡️ PlanetMinted: Minted token ${tokenId} for ${minter}`);
    }
  );

  process.stdin.resume();
}

main().catch(console.error);
