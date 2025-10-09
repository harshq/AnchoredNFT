import {
  readContract,
  simulateContract,
  waitForTransactionReceipt,
  writeContract,
  watchContractEvent,
} from "@wagmi/core";
import { Address, Log, parseEventLogs } from "viem";
import { config } from "@/configs/rainbowkit";

import anchoredNFTAbi from "@planet/abi/AnchoredNFT";
import React from "react";

export default function useAnchoredContract() {
  const unwatchRef = React.useRef<() => void | null>(null);

  const create = async (
    engine: string,
    collateralToken: string,
    amount: bigint
  ) => {
    const { request } = await simulateContract(config, {
      abi: anchoredNFTAbi,
      functionName: "create",
      address: process.env.NEXT_PUBLIC_ANCHORED_NFT_ADDRESS as Address,
      args: [engine, collateralToken, amount],
    });
    const hash = await writeContract(config, request);
    return await waitForTransactionReceipt(config, { hash });
  };

  const parseLogs = async (
    event: string,
    logs: Log<bigint, number, false>[]
  ) => {
    return parseEventLogs({
      abi: anchoredNFTAbi,
      eventName: event,
      logs,
    });
  };

  const getTokenUri = async (tokenId: bigint) => {
    return readContract(config, {
      abi: anchoredNFTAbi,
      functionName: "tokenURI",
      address: process.env.NEXT_PUBLIC_ANCHORED_NFT_ADDRESS as Address,
      args: [tokenId],
    }) as Promise<string>;
  };

  const listenToEvent = async (
    requestId: string,
    tokenId: string,
    minter: string
  ) => {
    if (unwatchRef.current) unwatchRef.current();

    return new Promise((resolve) => {
      const unwatch = watchContractEvent(config, {
        abi: anchoredNFTAbi,
        address: process.env.NEXT_PUBLIC_ANCHORED_NFT_ADDRESS as Address,
        eventName: "NFTMinted",
        args: [requestId, tokenId, minter],
        onLogs: (logs) => {
          resolve(logs);
        },
      });

      unwatchRef.current = unwatch;
    });
  };

  React.useEffect(() => {
    return () => {
      if (unwatchRef.current) {
        unwatchRef.current();
        unwatchRef.current = null;
      }
    };
  }, []);

  return { getTokenUri, create, parseLogs, listenToEvent };
}
