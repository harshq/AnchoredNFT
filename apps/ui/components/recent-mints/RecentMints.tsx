"use client"
import React from "react";
import { formatUnits } from "viem";
import { Meh } from 'lucide-react';
import RecentMintCard from "@/components/recent-mint-card";
import { useSuspenseQuery } from "@apollo/client/react";
import { RECENT_MINTS } from "@/queries/recent-mints";
import pairs from "@/data/token-pairs.json";
import collections from "@/data/collections.json";
import { usePathname, useSearchParams } from "next/navigation";

export default function RecentMints() {
    const params = usePathname();
    const collectionData = collections.data.filter(col => col.url === params)[0];
    const { data } = useSuspenseQuery(RECENT_MINTS, {
        variables: {
            engine: collectionData?.engine
        },
    });
    if (data["Token"].length === 0) {
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
                data["Token"].map(evd => {
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
                        />
                    )
                })
            }
        </>
    )
}