"use client"
import { useState } from "react";
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Anchor } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '../ui/button';

interface Props {
    withNav?: boolean
}

const Header = ({ withNav = false }: Props) => {
    const [collapsed, setCollapsed] = useState(false);
    return (
        <header className='fixed top-0 left-0 right-0 z-50 backdrop-blur-md h-screen'>
            <div className='container mx-auto py-2 px-1 flex items-center justify-between'>
                <div className='bg-indigo-600 flex items-center justify-center p-1 text-white rounded rounded-bl-2xl'>
                    <Anchor className='rotate-45' />
                    <span className='font-russo text-xl'>ANCHORED</span>
                </div>
                {
                    withNav && (
                        <nav className={cn('space-y-8 md:space-y-0 md:space-x-8 md:block fixed md:static hidden flex-col items-center md:flex-row backdrop-blur-md top-[56px] left-0 right-0 w-full h-screen md:h-auto md:w-auto', { flex: !collapsed })}>
                            <a href='#' className='font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate'>ABOUT</a>
                            <a href='#' className='font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate'>ROADMAP</a>
                            <a href='#' className='font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate'>TEAM</a>
                            <a href='#' className='font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate'>FAQ</a>
                            <a href='#' className='font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate'>DOCS</a>
                        </nav>
                    )
                }
                <div className='flex gap-x-2 items-center'>
                    <ConnectButton />
                    <Button onClick={() => setCollapsed(col => !col)} className='bg-transparent hover:bg-transparent raised md:hidden text-black shadow-none'>
                        <div className={cn("menu gap-y-1 flex flex-col justify-center items-center cursor-pointer", { 'open': !collapsed })}>
                            <span className="bar w-5 rounded h-0.5 bg-white transition-transform duration-500 ease-[cubic-bezier(0.5,0.2,0.2,1)]"></span>
                            <span className="bar w-5 rounded h-0.5 bg-white transition-opacity duration-500 ease-[cubic-bezier(0.1,0.8,0.1,1)]"></span>
                            <span className="bar w-5 rounded h-0.5 bg-white transition-transform duration-500 ease-[cubic-bezier(0.5,0.2,0.2,1)]"></span>
                        </div>
                    </Button>
                </div>
            </div>
        </header>
    );
}

export default Header;