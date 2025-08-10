"use client"

import React from 'react'
import { usePathname } from 'next/navigation'

import {
    Breadcrumb,
    BreadcrumbItem,
    BreadcrumbLink,
    BreadcrumbList,
    BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"

const HeaderBreadcrumbs: React.FC = () => {
    const path = usePathname()
    const crumbs = path.split("/").filter(crumb => !!crumb);

    return (
        <Breadcrumb>
            <BreadcrumbList>
                <BreadcrumbItem>
                    <BreadcrumbLink className='text-stone-300 hover:text-white'>home</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                {
                    crumbs.map(crumb => (
                        <BreadcrumbItem key={crumb}>
                            <BreadcrumbLink className='text-white hover:text-stone-300 font-light' >{crumb}</BreadcrumbLink>
                        </BreadcrumbItem>

                    ))
                }
            </BreadcrumbList>
        </Breadcrumb>
    );
}
export default HeaderBreadcrumbs;