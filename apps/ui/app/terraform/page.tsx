import React from 'react'
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query';

import Header from '@/components/header';
import TokenPreview from '@/components/token-preview';
import PlanetNftGenForm from '@/components/planet-nft-gen-form';
import { PreviewContextProvider } from '@/components/token-preview/previewContext';
import PlanetNftListBtn from '@/components/planet-nft-list-btn';

export default async function Terraform() {
    const queryClient = new QueryClient();
    return (
        <HydrationBoundary state={dehydrate(queryClient)}>
            <Header title="Terraform Planet" />
            <div className='max-w-3/5 mx-auto mt-10 mb-10'>
                <PreviewContextProvider>
                    <div className='flex'>
                        <TokenPreview />
                        <div className='px-5 flex flex-col gap-2 w-[300px]'>
                            <PlanetNftGenForm />
                            <PlanetNftListBtn />
                        </div>
                    </div>
                </PreviewContextProvider>
            </div>
        </HydrationBoundary>
    );
}