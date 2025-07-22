"use client"

import React from 'react'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import ListNftForm from '../list-nft-form'
import { Button } from '../ui/button'

const ListNftDialog = () => {
    return (
        <Dialog>
            <DialogTrigger asChild>
                <Button className='bg-blue-600 hover:bg-blue-800 font-bold text-md'>
                    Sell NFT
                </Button>
            </DialogTrigger>
            <DialogContent
                showCloseButton={false}
                onInteractOutside={e => e.preventDefault()}
                onEscapeKeyDown={e => e.preventDefault()}
                onOpenAutoFocus={e => e.preventDefault()}>
                <DialogHeader>
                    <DialogTitle>List NFT for Sale</DialogTitle>
                    <DialogDescription>
                        Review the details before listing your NFT on the marketplace. <br />A <b>1% service fee</b> applies upon successful sale. Proceeds will be transferred directly to the NFT owner.
                    </DialogDescription>
                </DialogHeader>
                <ListNftForm />
            </DialogContent>
        </Dialog>
    );
}
export default ListNftDialog;