import React from "react";
import MyMints from "@/components/my-mints/MyMints";

export default function page() {
    return (
        <div className="container mx-auto p-4">
            <h1 className="font-russo before:inline-block before:w-1 before:h-[calc(1rem+2px)] before:bg-indigo-500 before:mr-1.5 before:relative text-2xl">My NFTs</h1>
            <p className="text-xs text-gray-400">Your collection of minted NFTs</p>
            <div className="mt-8 grid grid-cols-2  xl:grid-cols-3 gap-1.5">
                <MyMints />
            </div>
        </div>
    )
}