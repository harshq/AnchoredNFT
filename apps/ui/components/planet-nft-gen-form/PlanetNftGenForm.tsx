"use client"

import { z } from 'zod';
import React from 'react'
import { Loader2Icon } from "lucide-react"
import { zodResolver } from '@/utils/ZodResolver';
import { useForm } from "react-hook-form";
import {
    simulateContract,
    writeContract,
    waitForTransactionReceipt,
    watchContractEvent
} from "@wagmi/core";
import { Address, parseEventLogs } from 'viem';

import abi from "@planet/abi/PlanetNFT";
import { config } from '@/configs/rainbowkit';

import schema from './schema'
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormMessage
} from '../ui/form';
import { Button } from '../ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { previewContext } from '../token-preview/previewContext';

const PlanetNftGenForm = () => {
    const context = React.use(previewContext);
    const [isLoading, setIsLoading] = React.useState(false);
    const [requestId, setRequestId] = React.useState<bigint | null>(null);
    const [mintSuccess, setMintSuccess] = React.useState(false);

    React.useEffect(() => {
        if (!requestId) return;
        const unwatch = watchContractEvent(config, {
            abi,
            address: process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address,
            eventName: 'PlanetMinted',
            args: {
                requestId
            },
            onLogs: (logs) => {
                const match = logs.find(
                    (log) => (log as any).args?.requestId === requestId
                );
                if (match) {
                    const tokenId = (match as any).args.tokenId;
                    setIsLoading(false)
                    setMintSuccess(true);
                    context?.setTokenId(tokenId);
                }
            },
            onError: () => {
                setIsLoading(false)
            }
        });

        return () => unwatch()

    }, [requestId])

    const form = useForm<z.infer<typeof schema>>({
        mode: 'all',
        resolver: zodResolver(schema),
        defaultValues: {
            pricefeedPair: 'BTC/USD'
        }
    });

    const onSubmit = async (params: z.infer<typeof schema>) => {
        try {
            setMintSuccess(false);
            setIsLoading(true);
            const { request } = await simulateContract(config, {
                abi,
                functionName: 'terraform',
                address: process.env.NEXT_PUBLIC_PLANET_NFT_ADDRESS as Address,
            })
            const hash = await writeContract(config, request);
            const receipt = await waitForTransactionReceipt(config, { hash });

            const events = await parseEventLogs({
                abi,
                eventName: 'PlanetRequested',
                logs: receipt.logs
            })

            if (events.length > 0) {
                const event = events[0] as any;
                if (event?.args?.requestId) {
                    const requestId = event?.args?.requestId;
                    setRequestId(requestId);
                }
            }
        } catch (error) {
            console.log(error)
            setIsLoading(false);
        }
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)}>
                <FormField
                    control={form.control}
                    name='pricefeedPair'
                    render={({ field }) => (
                        <FormItem className='hidden'>
                            <Select disabled defaultValue={"BTC/USD"} onValueChange={field.onChange} value={field.value}>
                                <FormControl>
                                    <SelectTrigger >
                                        <SelectValue placeholder="Select a verified email to display" />
                                    </SelectTrigger>
                                </FormControl>
                                <SelectContent>
                                    <SelectItem value="BTC/USD">BTC/USD</SelectItem>
                                    <SelectItem value="ETH/USD">ETH/USD</SelectItem>
                                </SelectContent>
                            </Select>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <Button disabled={isLoading} className='w-full' type='submit' variant='default'>
                    {isLoading ? <> <Loader2Icon className="animate-spin" />Working on it</> : <>✨ Terraform {mintSuccess ? "another" : ""}</>}
                </Button>
            </form>
        </Form>
    );
}
export default PlanetNftGenForm;