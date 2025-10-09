import { z } from "zod";

export default {
  "1": z.object({
    engine: z.string().trim().min(1, "Please select an engine"),
  }),
  "2": z.object({
    pair: z.string().min(1, "Please select a linked pair"),
    collateralAddress: z.string().optional(),
    collateralDecimals: z.number().optional(),
  }),
  "3": z.object({
    collateralAmount: z.string().min(1, "Invalid amount"),
  }),
  "4": z.object({}),
  "5": z.object({}),
};
