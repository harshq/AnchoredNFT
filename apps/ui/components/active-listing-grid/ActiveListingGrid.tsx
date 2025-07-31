"use client"

import React, { Suspense } from 'react'
import { useSuspenseQueries } from '@tanstack/react-query';


import { useActiveListing } from '@/app/queries/listing';
import { fetchTokenMeta } from '@/app/queries/metadata';

import ActiveListingItem from '../active-listing-item';
import ActiveListingGridPlaceholder from './ActiveListingGridPlaceholder';


const ActiveListingGrid = () => {


    const { data, isLoading } = useActiveListing()
    const metaQueries = useSuspenseQueries({
        queries: (data || []).map(listing => ({
            queryKey: ['active-listings', 'token', 'metadata', listing.token_id],
            queryFn: () => fetchTokenMeta(listing.token_address, listing.token_id),
            enabled: !!listing.contract_address && !!listing.token_id,
            staleTime: 1000 * 60 * 5
        }))
    });

    const isDataLoading = isLoading || metaQueries.some(meta => meta && meta.isLoading);
    const metas = metaQueries.map(q => q.data).filter(m => !!m);

    if (isDataLoading) {
        return <div>Loading data...</div>
    } else if (data.length === 0) {
        return <ActiveListingGridPlaceholder />
    }

    return (
        <div className="container mx-auto grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
            {
                metas.map(meta => (<ActiveListingItem key={meta.name} {...meta} />))
            }
        </div>
    )
}

const SuspenseWrapper = () => (
    <Suspense fallback={<span>loading...</span>}>
        <ActiveListingGrid />
    </Suspense>
)
export default SuspenseWrapper;