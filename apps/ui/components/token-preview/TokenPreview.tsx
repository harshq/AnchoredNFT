"use client"

import React from 'react'
import Image from 'next/image';

import { usePreviewContext } from './previewContext';

const TokenPreview: React.FC = () => {
    const { metadata } = usePreviewContext();
    return (
        <div className='h-[400px] w-[400px] border-1 rounded-md overflow-hidden'>
            {
                metadata && metadata?.image ? <Image src={metadata?.image} alt={metadata?.name} width={400} height={400} /> : null
            }
        </div>
    );
}
export default TokenPreview;