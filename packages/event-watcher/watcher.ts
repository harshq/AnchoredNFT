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

import VRFCoordinatorABI from "@anchored/abi/VRFCoordinatorV2_5Mock" with { type: "json" };
import AnchoredNFTABI from "@anchored/abi/AnchoredNFT" with { type: "json" };

async function main() {
  const provider = new JsonRpcProvider("http://localhost:8545");
  const wallet = new ethers.Wallet(DEFAULT_ANVIL_PRIVATE_KEY, provider);

  const vrf = new ethers.Contract(
    VRF_COORDINATOR_ADDRESS,
    VRFCoordinatorABI,
    wallet
  );

  const nft = new ethers.Contract(NFT_ADDRESS, AnchoredNFTABI, wallet);

  console.log("👀 Listening for contract events");
  nft.on(
    "NFTRequested",
    async (
      requestId: BigNumberish,
      tokenId: BigNumberish,
      _: any,
      __: any,
      minter: string
    ) => {
      console.log(
        `📡 NFTRequested: Detected request #${requestId.toString()} for token${tokenId.toString()} from ${minter}`
      );

      const rand1 = BigInt(keccak256(randomBytes(32)));
      // const rand2 = BigInt(keccak256(randomBytes(32)));
      try {
        const tx = await vrf.fulfillRandomWordsWithOverride(
          requestId,
          NFT_ADDRESS,
          [
            rand1,
            // rand2
          ]
        );
        await tx.wait();
        console.log(
          `📡 NFTRequested: Fulfilled ${requestId} with ${rand1.toString()}}`
        );
      } catch (err) {
        console.error("📡 NFTRequested: Fulfillment failed:", err);
      }
    }
  );

  nft.on(
    "NFTMinted",
    async (requestId: BigNumberish, tokenId: BigNumberish, minter: string) => {
      console.log(`⚡️ NFTMinted: Minted token ${tokenId} for ${minter}`);
    }
  );

  process.stdin.resume();
}

main().catch(console.error);
