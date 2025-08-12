"use client"
import React from 'react'
import { Button } from '../ui/button';
import useMetaMask from '@/hooks/useMetaMask';
import { usePreviewContext } from '../token-preview/previewContext';
import { Address } from 'viem';

const AddToMetaMask: React.FC = () => {
    const { addToMetaMask } = useMetaMask();
    const context = usePreviewContext();
    const addToWallet = () => {
        addToMetaMask({
            address: process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address,
            tokenId: context.tokenId?.toString(),
            symbol: "PNFT",
            image: context.metadata?.image
        })
    }
    return (
        <Button disabled={!context.tokenId} onClick={addToWallet}>Add to MetaMask</Button>
    );
}
export default AddToMetaMask;