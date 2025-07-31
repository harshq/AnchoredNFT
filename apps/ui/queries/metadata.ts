import { Address } from "viem";
import { readContract } from "@wagmi/core";

import abi from "@planet/abi/PlanetNFT";
import { config } from "@/configs/rainbowkit";
import { decodeBase64ToJson } from "@/utils/base64Helper";
import { Metadata } from "@/types/metadata";

export const fetchTokenMeta = async (
  tokenAddress?: string | null,
  tokenId?: string | null
): Promise<Metadata | null> => {
  if (!tokenAddress || !tokenId) {
    return null;
  }
  const raw = await readContract(config, {
    abi,
    address: tokenAddress as Address,
    functionName: "tokenURI",
    args: [tokenId],
  });

  return decodeBase64ToJson(raw as string);
};
