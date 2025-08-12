import React from "react";
import {
  simulateContract,
  writeContract,
  waitForTransactionReceipt,
} from "@wagmi/core";
import { Address } from "viem";

import { config } from "@/configs/rainbowkit";
import marketplaceAbi from "@planet/abi/NFTMarketplace";
import IERC721Abi from "@planet/abi/IERC721";

const NFT_MARKETPLACE_ADDRESS = process.env
  .NEXT_PUBLIC_NFT_MARKETPLACE_ADDRESS as Address;

type TxResponse = { success: boolean; error?: string };

export default function useMarketplace() {
  const getApprovalToList = async (
    contractAddress: Address,
    tokenId: bigint
  ): Promise<TxResponse> => {
    try {
      const { request } = await simulateContract(config, {
        abi: IERC721Abi,
        address: contractAddress,
        functionName: "approve",
        args: [NFT_MARKETPLACE_ADDRESS, tokenId],
      });

      const hash = await writeContract(config, request);
      await waitForTransactionReceipt(config, { hash });
      return { success: true };
    } catch (error) {
      console.log(error);
      return { success: false, error: (error as Error).message };
    }
  };

  const listItemOnMarketplace = async (
    contractAddress: Address,
    tokenId: bigint,
    price: bigint
  ): Promise<TxResponse> => {
    try {
      const { request } = await simulateContract(config, {
        abi: marketplaceAbi,
        address: NFT_MARKETPLACE_ADDRESS,
        functionName: "listItem",
        args: [contractAddress, tokenId, price],
      });
      const hash = await writeContract(config, request);
      await waitForTransactionReceipt(config, { hash });
      return { success: true };
    } catch (error) {
      console.log(error);
      return { success: false, error: (error as Error).message };
    }
  };

  return React.useMemo(
    () => ({
      getApprovalToList,
      listItemOnMarketplace,
    }),
    []
  );
}
