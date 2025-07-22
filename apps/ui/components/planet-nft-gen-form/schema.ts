import { z } from "zod";

export default z.object({
  pricefeedPair: z.string().optional(),
});
