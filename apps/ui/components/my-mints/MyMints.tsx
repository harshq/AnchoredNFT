"use client"

import React from "react";
import { formatUnits } from "viem";
import { Meh } from 'lucide-react';
import { useAccount } from "wagmi";
import { useQuery } from "@apollo/client/react";

import RecentMintCard from "@/components/recent-mint-card";
import { MY_RECENT_MINTS } from "@/queries/recent-mints";
import pairs from "@/data/token-pairs.json";

export default function MyMints() {
    const { address, isConnecting } = useAccount();
    const { data, loading } = useQuery(MY_RECENT_MINTS, {
        variables: {
            address: address?.toLowerCase()
        },
        fetchPolicy: "network-only",
        skip: !address
    });

    if (typeof window !== "undefined" && (isConnecting || loading)) {
        return <div>Loading...</div>
    }

    if (typeof data !== "object" || data["AnchoredNFT_NFTMinted"].length === 0) {
        return (
            <div className="border-1 border-gray-600/50 bg-white/10 rounded p-1 h-[370px] flex flex-col items-center justify-center">
                <Meh className="text-gray-500" />
                <div className="text-xs text-gray-500 mt-3">No Recent Mints</div>
            </div>
        )
    }

    return (
        <>
            {
                data["AnchoredNFT_NFTMinted"].map(evd => {
                    const collateralInfo = pairs.data.find(pair => pair.name === evd.metadata.attributes.pair)!;
                    const collateralAmountFormatted = formatUnits(BigInt(evd.metadata.attributes.amount), collateralInfo.token1.decimals);
                    return (
                        <RecentMintCard
                            key={evd.tokenId}
                            imageUrl={evd.metadata.image}
                            owner={evd.minter}
                            name={evd.metadata.name}
                            collection={evd.metadata.attributes.engine}
                            lockedValue={`${collateralAmountFormatted} ${collateralInfo.token1.symbol}`}
                            syncedPair={evd.metadata.attributes.pair}
                            hideAddress
                        />
                    )
                })
            }
        </>
    )
}