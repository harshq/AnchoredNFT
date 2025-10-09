import { config } from "@/configs/rainbowkit";
import {
  simulateContract,
  waitForTransactionReceipt,
  writeContract,
} from "@wagmi/core";
import { Address } from "viem";
import erc20Abi from "@planet/abi/IERC20";

export default function useERC20() {
  const approveFunds = async (
    tokenAddress: string,
    amount: bigint,
    spender: string = process.env.NEXT_PUBLIC_ANCHORED_NFT_VAULT_ADDRESS!
  ) => {
    const { request } = await simulateContract(config, {
      abi: erc20Abi,
      functionName: "approve",
      address: tokenAddress as Address,
      args: [spender, amount],
    });

    const hash = await writeContract(config, request);
    return await waitForTransactionReceipt(config, { hash });
  };

  return {
    approveFunds,
  };
}
