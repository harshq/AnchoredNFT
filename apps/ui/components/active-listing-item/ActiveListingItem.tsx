"use client"
import React from "react";
import Image from "next/image";
import { FastAverageColor } from 'fast-average-color';
import { motion, AnimatePresence } from "motion/react"
import { MetadataMerged } from "../../types/metadata";
import { Badge } from "../ui/badge";
import { formatUnits } from "viem";
import ActiveListingItemLoading from "./ActiveListingItemLoading";
import { ItemListed } from "@/queries/listing";
import { useQuery } from "@tanstack/react-query";
import { fetchTokenMeta } from "@/queries/metadata";

const ActiveListingItem = ({
    contract_address,
    token_address,
    token_id,
    price
}: ItemListed) => {
    const [isLoaded, setIsLoaded] = React.useState(false);
    const { data: metadata, isSuccess } = useQuery({
        queryKey: ['active-listings', 'token', 'metadata', token_id],
        queryFn: () => fetchTokenMeta(token_address, token_id),
        enabled: !!contract_address && !!token_id,
        staleTime: 1000 * 60 * 5
    });

    const ref = React.useRef<HTMLDivElement>(null);
    const onLoadingComplete = React.useCallback((img: HTMLImageElement) => {
        const fac = new FastAverageColor();
        fac.getColorAsync(img)
            .then(color => {
                if (!color.error && ref.current) {
                    ref.current.style.background = `radial-gradient(${color.hex}, black)`;
                }

                setTimeout(() => {
                    setIsLoaded(true);
                }, 200);
            })
            .catch(e => {
                console.log(e);
                setIsLoaded(true);
            });
    }, []);

    const isReady = isSuccess && isLoaded;

    return (
        <div ref={ref} className="relative overflow-hidden max-h-[520px]">
            <AnimatePresence>
                {!isReady && <motion.div
                    className="bg-stone-50 absolute h-[520px] w-full flex items-center justify-center z-1"
                    initial={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.3 }}>
                    <svg className="h-6 w-6 animate-spin stroke-gray-500" viewBox="0 0 256 256">
                        <line x1="128" y1="32" x2="128" y2="64" stroke-linecap="round" stroke-linejoin="round" stroke-width="24"></line>
                        <line x1="195.9" y1="60.1" x2="173.3" y2="82.7" stroke-linecap="round" stroke-linejoin="round"
                            stroke-width="24"></line>
                        <line x1="224" y1="128" x2="192" y2="128" stroke-linecap="round" stroke-linejoin="round" stroke-width="24">
                        </line>
                        <line x1="195.9" y1="195.9" x2="173.3" y2="173.3" stroke-linecap="round" stroke-linejoin="round"
                            stroke-width="24"></line>
                        <line x1="128" y1="224" x2="128" y2="192" stroke-linecap="round" stroke-linejoin="round" stroke-width="24">
                        </line>
                        <line x1="60.1" y1="195.9" x2="82.7" y2="173.3" stroke-linecap="round" stroke-linejoin="round"
                            stroke-width="24"></line>
                        <line x1="32" y1="128" x2="64" y2="128" stroke-linecap="round" stroke-linejoin="round" stroke-width="24"></line>
                        <line x1="60.1" y1="60.1" x2="82.7" y2="82.7" stroke-linecap="round" stroke-linejoin="round" stroke-width="24">
                        </line>
                    </svg>
                </motion.div>}
            </AnimatePresence>
            {
                metadata != null && typeof metadata === 'object' ? (
                    <div className="p-5">
                        <div className="relative overflow-hidden rounded-md aspect-square">
                            <Image onLoadingComplete={onLoadingComplete} src={metadata.image} alt={`${name}-image`} fill />
                        </div>
                        <div className="py-4 flex flex-col gap-2 mt-3">
                            <p className="font-bold text-white line-clamp-1">{metadata.name}</p>
                            <p className="text-sm text-neutral-400 line-clamp-3">{metadata.description}</p>
                        </div>

                        <div className="flex items-center justify-between">
                            <div>{metadata.attributes.map(badge => <Badge key={badge.value}>{badge.value}</Badge>)}</div>
                            <span className="text-white text-sm font-bold">{price ? `${formatUnits(BigInt(price), 8)} USDT` : '-'}</span>
                        </div>
                    </div>
                ) : null
            }

        </div>
    );
}
export default ActiveListingItem;