"use client";

import Link from "next/link";
import { Button } from "../ui/button";
import { Tooltip, TooltipTrigger, TooltipContent } from "../ui/tooltip";

interface Props {
    collectionSlug: string
    collectionName: string
    disabled: boolean
}

export default function MintButton({ collectionName, collectionSlug, disabled }: Props) {
    return (
        <Tooltip>
            <TooltipTrigger disabled asChild>
                <Link
                    onClick={(e) => disabled && e.preventDefault()}
                    href={`/collections/${collectionSlug}/mint`}>

                    <Button disabled={disabled} className='bg-indigo-500 hover:bg-indigo-600 cursor-pointer'>
                        {`Mint your own ${collectionName}`}
                    </Button>
                </Link>
            </TooltipTrigger>
            {
                disabled && (
                    <TooltipContent>
                        This mint has ended
                    </TooltipContent>
                )
            }
        </Tooltip>
    )
}