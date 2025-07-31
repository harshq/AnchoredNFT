"use client"
import React from "react";
import Image from "next/image";
import { FastAverageColor } from 'fast-average-color';
import { Metadata } from "../../app/types/metadata";

const ActiveListingItem = ({
    name,
    image,
    description,
    attributes
}: Metadata) => {
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
        <div ref={ref} className="rounded-md overflow-hidden">
            <Image onLoadingComplete={onLoadingComplete} src={image} alt={`${name}-image`} width={400} height={400} />
            <div className="p-4 flex flex-col gap-2 mt-3">
                <p className="font-bold text-white">{name}</p>
                <p className="text-sm text-neutral-400">{description}</p>
            </div>

        </div>
    );
}
export default ActiveListingItem;