import { config } from "@/configs/rainbowkit";
import {
  simulateContract,
  waitForTransactionReceipt,
  writeContract,
  readContract,
} from "@wagmi/core";
import { Address } from "viem";
import erc20Abi from "@anchored/abi/IERC20";

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

  const checkbalance = async (tokenAddress: string, userAddress: string) => {
    return (await readContract(config, {
      abi: erc20Abi,
      functionName: "balanceOf",
      address: tokenAddress as Address,
      args: [userAddress],
    })) as Promise<number>;
  };

  return {
    approveFunds,
    checkbalance,
  };
}
