"use client"

import React from 'react'
import { z } from 'zod'
import { Resolver, useForm } from "react-hook-form";
import { parseUnits, formatUnits, Address } from 'viem';

import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form"
import {
    DialogClose
} from "@/components/ui/dialog"

import schema from './schema';
import { Input } from '../ui/input';
import { Button } from '../ui/button';
import { formatNumberWithCommas, sanatiseNumberInput } from '@/utils/NumericInputFormatter'
import { zodResolver } from '@/utils/ZodResolver';
import useMarketplace from '@/hooks/useMarketplace';

const convertRawToBigInt = (val: string) => {
    let priceBigInt = 0n;
    try {
        priceBigInt = parseUnits(val, 6);;
    } catch { }

    return priceBigInt;
}

interface Props {
    defaultValues?: {
        contractAddress?: Address
        tokenId?: bigint
    }
}

const ListNftForm = ({ defaultValues }: Props) => {
    const { getApprovalToList, listItemOnMarketplace } = useMarketplace()

    const hasDefaultValues = defaultValues && Object.keys(defaultValues).length > 1;
    const form = useForm<z.input<typeof schema>>({
        mode: 'all',
        resolver: zodResolver(schema) as unknown as Resolver<z.input<typeof schema>>,
        defaultValues: {
            contractAddress: defaultValues?.contractAddress ? defaultValues.contractAddress.toString() : "",
            tokenId: defaultValues?.tokenId ? defaultValues.tokenId.toString() : "",
            price: ""
        }
    });

    const priceRaw = form.watch("price");
    const { fee, net } = React.useMemo(() => {
        const price = convertRawToBigInt(priceRaw);
        const fee = (price * 1n) / 100n;  // 1% fee
        const net = price - fee;
        return {
            fee, net
        }
    }, [priceRaw])

    const onSubmit = async (rawParams: any) => {
        const params = rawParams satisfies z.infer<typeof schema>;
        try {
            const approval = await getApprovalToList(params.contractAddress, params.tokenId);
            if (!approval.success) {
                console.error(`Approval failed:`, approval.error);
                return;
            };

            const listing = await listItemOnMarketplace(params.contractAddress, params.tokenId, params.price);
            if (!listing.success) {
                console.error(`Listing failed:`, listing.error);
                return;
            };
        } catch (error) {
            console.error(`Unexpected error`, error)
        }
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className=' flex flex-col gap-5'>
                <FormField
                    control={form.control}
                    name="contractAddress"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel className='text-sm text-gray-700'>NFT Contract Address</FormLabel>
                            <FormControl>
                                <Input placeholder="0x" {...field} readOnly={hasDefaultValues} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name='tokenId'
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel className='text-sm text-gray-700'>Token Id</FormLabel>
                            <FormControl>
                                <Input readOnly={hasDefaultValues} placeholder='1' {...field} onChange={e => {
                                    const safeValue = sanatiseNumberInput(e.target.value, false);
                                    field.onChange(safeValue);
                                }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name='price'
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel className='text-sm text-gray-700'>Price (USDT)</FormLabel>
                            <FormControl>
                                <Input placeholder='0.1' {...field} value={formatNumberWithCommas(field.value)} onChange={(e) => {
                                    const safeValue = sanatiseNumberInput(e.target.value, true);
                                    field.onChange(safeValue);
                                }} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                {
                    priceRaw && (<div className="text-sm text-muted-foreground mt-2 flex flex-col gap-1">
                        <div>Marketplace fee (1%): {formatNumberWithCommas(formatUnits(fee, 6))} USDT</div>
                        <div>Net proceeds: {formatNumberWithCommas(formatUnits(net, 6))} USDT</div>
                    </div>)
                }

                <div className="flex gap-2 w-full justify-end">
                    <DialogClose asChild><Button className='px-10' type="button" variant="outline">Cancel</Button></DialogClose>
                    <Button className='px-10' type='submit'>List NFT</Button>
                </div>
            </form>
        </Form>
    );
}
export default ListNftForm;