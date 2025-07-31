import { Address } from "viem";
import { readContract } from "@wagmi/core";

import abi from "@planet/abi/PlanetNFT";
import { MetadataPlus } from "@/app/types/metadata";
import { config } from "@/app/configs/rainbowkit";
import { decodeBase64ToJson } from "@/utils/base64Helper";

export const fetchTokenMeta = async (
  tokenAddress?: string | null,
  tokenId?: string | null
): Promise<MetadataPlus | null> => {
  if (!tokenAddress || !tokenId) {
    return null;
  }
  const raw = await readContract(config, {
    abi,
    address: tokenAddress as Address,
    functionName: "tokenURI",
    args: [tokenId],
  });

  const decoded = decodeBase64ToJson(raw as string);

  return {
    ...decoded,
    tokenAddress,
    tokenId,
  };
};
