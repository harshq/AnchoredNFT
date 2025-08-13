"use client"
import React from 'react'
import { usePreviewContext } from '../token-preview/previewContext';
import { Address } from 'viem';

const PLANET_NFT_ADDRESS = process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address;

const PlanetNftGenData: React.FC = () => {
    const context = usePreviewContext();

    if (!context) {
        return;
    }
    return (
        <div>
            <pre>
                {JSON.stringify({ ...context, metadata: { ...context.metadata, image: '', description: '' }, contract: PLANET_NFT_ADDRESS }, (_, value) =>
                    typeof value === 'bigint' ? Number(value) : value, 4)}
            </pre>
        </div>
    );
}
export default PlanetNftGenData;