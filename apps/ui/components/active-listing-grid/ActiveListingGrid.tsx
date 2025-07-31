"use client"

import React, { Suspense } from 'react'

import { useActiveListing } from '@/queries/listing';
import ActiveListingItem from '../active-listing-item';

const ActiveListingGrid = () => {
    const { data } = useActiveListing()
    return (
        <div className="mx-auto grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
            {
                data.map(item => (<ActiveListingItem key={item.rindexer_id} {...item} />))
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