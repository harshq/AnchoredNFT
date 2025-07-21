import { z } from "zod";
import { isAddress, parseUnits } from "viem";

export default z.object({
  contractAddress: z
    .string()
    .trim()
    .min(1, "Invalid contract address")
    .refine(isAddress, "Invalid contract address"),
  tokenId: z
    .string()
    .min(1, "Invalid token ID")
    .refine((val) => {
      try {
        const num = BigInt(val);
        return num >= 0;
      } catch {
        return false;
      }
    }, "Invalid Token ID")
    .transform((val) => BigInt(val)),
  price: z
    .string()
    .min(1, "Invalid USDT amount")
    .refine((val) => {
      try {
        parseUnits(val, 6);
        return true;
      } catch {
        return false;
      }
    }, "Invalid USDT amount")
    .transform((val) => parseUnits(val, 6)),
});
