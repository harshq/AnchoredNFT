"use client"

import React from "react";
import { formatUnits } from "viem";
import { Meh } from 'lucide-react';
import { useAccount } from "wagmi";
import { useQuery } from "@apollo/client/react";
import { EllipsisVertical, Loader } from "lucide-react";

import RecentMintCard from "@/components/recent-mint-card";
import { MY_RECENT_MINTS } from "@/queries/recent-mints";
import pairs from "@/data/token-pairs.json";
import { Button } from "@/components/ui/button";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "../ui/dropdown-menu";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import useAnchoredContract from "@/hooks/useAnchoredContract";


const DELETE_STATE = {
    "IDLE": "IDLE",
    "DELETING": "DELETING",
    "FAILED": "FAILED",
    "SUCCESS": "SUCCESS"
} as const;

type DeleteState = typeof DELETE_STATE[keyof typeof DELETE_STATE];

export default function MyMints() {
    const { address, isConnecting } = useAccount();
    const { destroy } = useAnchoredContract();
    const [isDialogOpen, setIsDialogOpen] = React.useState(false)
    const [destroyState, setDestryState] = React.useState<DeleteState>(DELETE_STATE.IDLE);
    const { data, loading, refetch } = useQuery(MY_RECENT_MINTS, {
        variables: {
            address: address?.toLowerCase()
        },
        fetchPolicy: "network-only",
        skip: !address
    });

    React.useEffect(() => {
        if (destroyState === DELETE_STATE.SUCCESS) {
            setIsDialogOpen(false);
            refetch();
        }
    }, [destroyState])

    if (typeof window !== "undefined" && (isConnecting || loading)) {
        return <div>Loading...</div>
    }

    if (typeof data !== "object" || data["Token"].length === 0) {
        return (
            <div className="border-1 border-gray-600/50 bg-white/10 rounded p-1 h-[370px] flex flex-col items-center justify-center">
                <Meh className="text-gray-500" />
                <div className="text-xs text-gray-500 mt-3">No Recent Mints</div>
            </div>
        )
    }

    const onClickDelete = async (e: React.MouseEvent<HTMLButtonElement, MouseEvent>, tokenId: string, collateral: string) => {
        e.preventDefault();
        setDestryState(DELETE_STATE.DELETING)
        try {
            const hash = await destroy(tokenId, collateral);
            console.log(hash);
            setDestryState(DELETE_STATE.SUCCESS)
        } catch (error) {
            setDestryState(DELETE_STATE.FAILED)
            console.log(error);
        }
    }

    const onOpenChange = () => {
        if (destroyState === DELETE_STATE.DELETING) return;
        setIsDialogOpen(state => !state)
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
                            hideAddress
                            cta={
                                <div className="absolute top-3 right-3">
                                    <AlertDialog open={isDialogOpen} onOpenChange={onOpenChange}>
                                        <DropdownMenu>
                                            <DropdownMenuTrigger asChild>
                                                <Button variant="ghost" className="rounded-full size-8">
                                                    <EllipsisVertical />
                                                </Button>
                                            </DropdownMenuTrigger>
                                            <DropdownMenuContent className="bg-white" align="end">
                                                <AlertDialogTrigger>
                                                    <DropdownMenuItem>
                                                        Liqidate NFT
                                                    </DropdownMenuItem>
                                                </AlertDialogTrigger>
                                            </DropdownMenuContent>
                                        </DropdownMenu>

                                        <AlertDialogContent className="bg-white text-background">
                                            <AlertDialogHeader>
                                                <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
                                                <AlertDialogDescription>
                                                    This action cannot be undone. This will permanently delete your NFT and move collataral to your connected wallet
                                                </AlertDialogDescription>
                                            </AlertDialogHeader>
                                            <AlertDialogFooter>
                                                <AlertDialogCancel disabled={destroyState === DELETE_STATE.DELETING} className="bg-white">Cancel</AlertDialogCancel>
                                                <AlertDialogAction disabled={destroyState === DELETE_STATE.DELETING} onClick={(e) => onClickDelete(e, evd.tokenId, evd.metadata.attributes.collateral)} className="bg-red-800 hover:bg-red-900 min-w-[150px]">{destroyState === DELETE_STATE.DELETING ? <Loader className="animate-spin" /> : "Delete my NFT and Liquidate"}</AlertDialogAction>
                                            </AlertDialogFooter>
                                        </AlertDialogContent>
                                    </AlertDialog>
                                </div >
                            }
                        />
                    )
                })
            }
        </>
    )
}