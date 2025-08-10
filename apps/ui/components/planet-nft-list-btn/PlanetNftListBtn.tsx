"use client"

import React from 'react'
import { usePreviewContext } from '../token-preview/previewContext';
import { Button } from '../ui/button';
import ListNftDialog from '../list-nft-dialog';
import { Address } from 'viem';

const PlanetNftListBtn: React.FC = () => {
    const context = usePreviewContext();
    const defaultValues = React.useMemo(() => ({
        contractAddress: process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address,
        tokenId: context.tokenId!
    }), [context.tokenId])

    return (
        <>
            <ListNftDialog defaultValues={defaultValues} trigger={
                <Button className='w-full' disabled={!context.metadata?.image}>List NFT</Button>
            } />
        </>
    );
}
export default PlanetNftListBtn;