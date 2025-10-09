"use client";
import React from 'react'
import { Button } from '../ui/button';
import { useSidebar } from '../ui/sidebar';
import { cn } from '@/lib/utils';

const SidebarTrigger: React.FC = () => {
    const { openMobile, setOpenMobile } = useSidebar();

    return (
        <Button onClick={() => setOpenMobile(!openMobile)} className='bg-transparent hover:bg-transparent raised md:hidden text-black shadow-none'>
            <div className={cn("menu gap-y-1 flex flex-col justify-center items-center cursor-pointer", { 'open': openMobile })}>
                <span className="bar w-5 rounded h-0.5 bg-white transition-transform duration-500 ease-[cubic-bezier(0.5,0.2,0.2,1)]"></span>
                <span className="bar w-5 rounded h-0.5 bg-white transition-opacity duration-500 ease-[cubic-bezier(0.1,0.8,0.1,1)]"></span>
                <span className="bar w-5 rounded h-0.5 bg-white transition-transform duration-500 ease-[cubic-bezier(0.5,0.2,0.2,1)]"></span>
            </div>
        </Button>
    );
}
export default SidebarTrigger;