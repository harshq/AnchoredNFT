"use client"

import React from 'react'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
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
        >
            <DialogHeader>
                <DialogTitle>Terraform a new Planet NFT</DialogTitle>
                <PlanetNftGenForm />
            </DialogHeader>
        </DialogContent>
    </Dialog>);
}
export default PlanetNftGenDialog;