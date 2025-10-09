"use client";

import ConnectWallet from "@/components/connect-wallet";
import SideBarContent from "@/components/sidebar-content";
import SidebarTrigger from "@/components/sidebar-trigger";
import { SidebarProvider } from "@/components/ui/sidebar";
import { Anchor } from "lucide-react";
import React from "react";

export default function Layout({ children }: {
    children: React.ReactNode
}) {
    return (
        <SidebarProvider>
            <div className="fixed top-0 right-0 left-0 h-14 bg-vivid flex justify-between items-center z-[60] shadow-lg">
                <div className="w-[16rem] flex justify-start md:justify-center">
                    <SidebarTrigger />
                    <div className='bg-indigo-600 flex items-center justify-center p-1 text-white rounded rounded-bl-2xl'>
                        <Anchor className='rotate-45' />
                        <span className='font-russo text-xl'>ANCHORED</span>
                    </div>
                </div>
                <div className="pr-3">
                    <ConnectWallet />
                </div>
            </div>
            <SideBarContent />
            <main className="w-full mt-14">
                {children}
            </main>
        </SidebarProvider>
    )
}