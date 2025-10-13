import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Image from "next/image";
import { LockKeyhole, ArrowLeftRight } from 'lucide-react';
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";

export interface Props {
    imageUrl: string
    owner: string
    name: string
    collection: string
    lockedValue: string
    syncedPair: string
    hideAddress?: boolean
}

export default function RecentMintCard({
    imageUrl,
    owner,
    name,
    collection,
    lockedValue,
    syncedPair,
    hideAddress = false
}: Props) {
    return (
        <div className="border-1 border-gray-600/50 bg-white/10 rounded p-1 group/card">
            <div className="aspect-square w-full relative rounded overflow-hidden ">
                <Image className="transition-transform duration-500 ease-in-out group-hover/card:scale-110" objectFit="cover" src={imageUrl} alt="recent mint" fill />
                {
                    !hideAddress && (<Button className="absolute bottom-1 right-1 rounded-2xl px-1 py-0.5 h-min bg-white flex items-center gap-1 max-w-[calc(100%-100px)] hover:bg-white">
                        <Image src={"/icons/eth.svg"} alt="ethereum icon" height={20} width={20} />
                        <span className="text-gray-500 text-xs text-ellipsis-middle">{owner}</span>
                    </Button>)
                }
            </div>
            <div className="p-2">
                <h3 className="font-medium text-md">{name}</h3>
                <p className="text-xs text-gray-400">From <span className="font-medium hover:underline hover:text-white cursor-pointer transition-all">{collection}</span></p>

                <div className="mt-3 flex flex-wrap gap-1">
                    <Tooltip><TooltipTrigger asChild><Badge className="bg-indigo-900 cursor-default"><LockKeyhole />{lockedValue}</Badge></TooltipTrigger><TooltipContent>Locked Collateral</TooltipContent></Tooltip>
                    <Tooltip><TooltipTrigger asChild><Badge className="bg-indigo-900 cursor-default"><ArrowLeftRight />{syncedPair}</Badge></TooltipTrigger><TooltipContent>Synced Pair</TooltipContent></Tooltip>
                </div>
            </div>
        </div>
    )
}