import { config } from "@/configs/rainbowkit";
import {
  simulateContract,
  waitForTransactionReceipt,
  writeContract,
} from "@wagmi/core";
import React from "react";
import { Address } from "viem";
import marketplaceAbi from "@planet/abi/NFTMarketplace";
import ierc20Abi from "@planet/abi/IERC20";

const NFT_MARKETPLACE_ADDRESS = process.env
  .NEXT_PUBLIC_NFT_MARKETPLACE_ADDRESS as Address;

type TxResponse = { success: boolean; error?: string };

interface PurchaseNFT {
  address: Address;
  tokenId: bigint;
  price: bigint;
}

export default function usePurchaseNFT() {
  const purchase = async ({
    address,
    tokenId,
    price,
  }: PurchaseNFT): Promise<TxResponse> => {
    try {
      // 1. Approve tokens
      const { request: approveRequest } = await simulateContract(config, {
        address: process.env.NEXT_PUBLIC_PAYMENT_TOKEN_ADDRESS as Address,
        abi: ierc20Abi,
        functionName: "approve",
        args: [NFT_MARKETPLACE_ADDRESS, price],
      });
      const approveHash = await writeContract(config, approveRequest);
      await waitForTransactionReceipt(config, { hash: approveHash });

      console.log("APPROVED!");

      // 2. Purchase
      const { request } = await simulateContract(config, {
        abi: marketplaceAbi,
        address: NFT_MARKETPLACE_ADDRESS,
        functionName: "buyItem",
        args: [address, tokenId],
      });

      const hash = await writeContract(config, request);
      await waitForTransactionReceipt(config, { hash });
      return { success: true };
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  };

  return React.useMemo(
    () => ({
      purchase,
    }),
    []
  );
}
