"use client";
import React from "react";
import { Address } from "viem";

interface AddToMetaMask {
  address: Address;
  tokenId?: string | null;
  symbol: string;
  image?: string;
}

export default function useMetaMask() {
  const addToMetaMask = async ({
    address,
    tokenId,
    symbol,
    image,
  }: AddToMetaMask) => {
    if (typeof window.ethereum === undefined) {
      alert(`MetaMask not installed`);
      return;
    }

    // if (!address || tokenId === null || !image) {
    //   return;
    // }

    try {
      console.log("HERE", address, tokenId);
      const isAdded = await window.ethereum.request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC721",
          options: {
            address,
            tokenId,
            // symbol,
            // image,
          },
        },
      });

      if (isAdded) {
        alert(`Added to MetaMask`);
      } else {
        alert(`Failed`);
      }
    } catch (error) {
      alert(`Failed`);
    }
  };

  return React.useMemo(
    () => ({
      addToMetaMask,
    }),
    []
  );
}
