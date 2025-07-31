"use client"
import React from "react";
import Image from "next/image";
import { FastAverageColor } from 'fast-average-color';
import { MetadataMerged } from "../../types/metadata";
import { Badge } from "../ui/badge";
import { formatUnits } from "viem";



const ActiveListingItem = ({
    name,
    image,
    description,
    attributes,
    price
}: MetadataMerged) => {
    const [] = React.useState();
    const ref = React.useRef<HTMLDivElement>(null);
    const onLoadingComplete = React.useCallback((img: HTMLImageElement) => {
        const fac = new FastAverageColor();
        fac.getColorAsync(img)
            .then(color => {
                if (!color.error && ref.current) {
                    ref.current.style.background = `radial-gradient(${color.hex}, black)`;
                }
            })
            .catch(e => {
                console.log(e);
            });
    }, []);
    return (
        <div ref={ref} className="overflow-hidden p-5">
            <div className="relative overflow-hidden rounded-md aspect-square">
                <Image onLoadingComplete={onLoadingComplete} src={image} alt={`${name}-image`} fill />
            </div>
            <div className="py-4 flex flex-col gap-2 mt-3">
                <p className="font-bold text-white">{name}</p>
                <p className="text-sm text-neutral-400">{description}</p>
            </div>

            <div className="flex items-center justify-between">
                <div>{attributes.map(a => <Badge>{a.value}</Badge>)}</div>
                <span className="text-white text-sm font-bold">{price ? `${formatUnits(BigInt(price), 8)} USDT` : '-'}</span>
            </div>
        </div>
    );
}
export default ActiveListingItem;