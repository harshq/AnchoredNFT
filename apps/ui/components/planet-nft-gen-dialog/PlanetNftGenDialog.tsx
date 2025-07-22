"use client"

import React from 'react'
import {
    Dialog,
    DialogContent,
    // DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
// import ListNftForm from '../list-nft-form'
import { Button } from '../ui/button'
import PlanetNftGenForm from '../planet-nft-gen-form'

const PlanetNftGenDialog = () => {
    return (<Dialog>
        <DialogTrigger asChild>
            <Button className='bg-blue-600 hover:bg-blue-800 font-bold text-md'>
                Terraform Planet
            </Button>
        </DialogTrigger>
        <DialogContent
        // showCloseButton={false}
        // onInteractOutside={e => e.preventDefault()}
        // onEscapeKeyDown={e => e.preventDefault()}
        // onOpenAutoFocus={e => e.preventDefault()}
        >
            <DialogHeader>
                <DialogTitle>Terraform a new Planet NFT</DialogTitle>
                <PlanetNftGenForm />
            </DialogHeader>
        </DialogContent>
    </Dialog>);
}
export default PlanetNftGenDialog;