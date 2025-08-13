"use client"

import React from "react";
import { Address } from "viem";
import { readContract } from "@wagmi/core";

import abi from "@planet/abi/PlanetNFT";
import { config } from '@/configs/rainbowkit';
import { decodeBase64ToJson } from "@/utils/base64Helper";
import { Metadata } from "@/types/metadata";

const PLANET_NFT_ADDRESS = process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address;

interface PreviewContextType {
  tokenId: bigint | null;
  setTokenId: (tokenId: bigint) => void
  metadata: Metadata | null
}

export const previewContext = React.createContext<PreviewContextType | undefined>(undefined);

interface ProviderProps {
  children: React.ReactNode
}

export const PreviewContextProvider = ({ children }: ProviderProps) => {
  const [tokenId, setTokenId] = React.useState<bigint | null>(null)
  const [metadata, setMetadata] = React.useState<Metadata | null>(null)

  const fetchTokenMeta = async (tokenId: bigint) => {
    try {
      const data = await readContract(config, {
        abi,
        address: PLANET_NFT_ADDRESS,
        functionName: 'tokenURI',
        args: [tokenId]
      });

      const parsed = decodeBase64ToJson(data as string);
      console.log({
        ...parsed,
        tokenId,
        contract: PLANET_NFT_ADDRESS
      });
      setMetadata(parsed)
    } catch (error) {
      console.log(error);
    }
  }

  React.useEffect(() => {
    if (tokenId !== null) fetchTokenMeta(tokenId);
  }, [tokenId]);

  return (
    <previewContext.Provider value={{
      tokenId,
      setTokenId,
      metadata
    }}>
      {children}
    </previewContext.Provider>
  )
}

export const usePreviewContext = () => {
  const context = React.use(previewContext);
  if (!context) throw new Error("usePreviewContext should be used within PreviewContextProvider");
  return context;
}