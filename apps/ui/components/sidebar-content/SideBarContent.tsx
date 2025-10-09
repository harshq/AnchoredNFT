"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Sidebar, SidebarContent, SidebarGroup, SidebarGroupContent, SidebarGroupLabel } from "../ui/sidebar";
import { cn } from "@/lib/utils";

export default function SideBarContent() {
    const pathname = usePathname()
    return (
        <Sidebar variant="sidebar" className="border-none">
            <SidebarContent>
                <SidebarGroup className="md:mt-20">
                    <SidebarGroupLabel className="text-white/30">Navigation</SidebarGroupLabel>
                    <SidebarGroupContent>
                        <nav className="flex flex-col gap-y-4 p-2">
                            <Link href="/explore" className={cn("font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate", { 'text-transparent': pathname === '/explore' })}>Explore</Link>
                            <Link href="/profile" className={cn("font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate", { 'text-transparent': pathname === '/profile' })}>My NFTs</Link>
                            <Link href="/collections" className={cn("font-russo text-gray-300 hover:text-transparent transition-colors duration-200 bg-clip-text vivid-background vivid-animate", { 'text-transparent': pathname.includes('/collections') })}>Collections</Link>
                        </nav>
                    </SidebarGroupContent>
                </SidebarGroup>
                <SidebarGroup />
            </SidebarContent>

        </Sidebar>
    )
}