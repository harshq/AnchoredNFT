import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { anvil } from "wagmi/chains";

export const config = getDefaultConfig({
  appName: "Planet Marketplace",
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PID!,
  chains: [anvil],
  ssr: true, // If your dApp uses server side rendering (SSR)
});
