import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { createStorage, cookieStorage } from "wagmi";
import { anvil } from "wagmi/chains";

export const config = getDefaultConfig({
  appName: "Planet Marketplace",
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PID!,
  chains: [anvil],
  ssr: false,
});
