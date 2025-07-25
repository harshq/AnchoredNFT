import { zodResolver } from '@/utils/ZodResolver';
import React from 'react'
import { useForm } from "react-hook-form";
import schema from './schema'
import {
    Form,
    FormControl,
    FormField,
    FormItem,
    FormMessage
} from '../ui/form';
import { Button } from '../ui/button';
import { z } from 'zod';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import abi from "@planet/abi/PlanetNFT";
import { simulateContract, writeContract, waitForTransactionReceipt } from "@wagmi/core";
import { config } from '@/app/configs/rainbowkit';

const PLANET_NFT_ADDRESS = '0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82';

const PlanetNftGenForm = () => {
    const form = useForm<z.infer<typeof schema>>({
        mode: 'all',
        resolver: zodResolver(schema),
        defaultValues: {

        }
    });

    const onSubmit = async (params: z.infer<typeof schema>) => {
        try {
            const { request } = await simulateContract(config, {
                abi,
                functionName: 'terraform',
                address: PLANET_NFT_ADDRESS,
            })

            console.log("1", request);

            const hash = await writeContract(config, {
                abi,
                functionName: 'terraform',
                address: PLANET_NFT_ADDRESS,
            });

            console.log("2", hash);

            const receipt = await waitForTransactionReceipt(config, { hash });
            console.log("3", receipt);
            // if (receipt.status == "success") {
            //     console.log(receipt);
            // }



        } catch (error) {
            console.log("CATCH BLOCK");
            console.log(error)

        }

    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)}>
                <FormField
                    control={form.control}
                    name='pricefeedPair'
                    render={({ field }) => (
                        <FormItem>
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
                <Button type='submit' variant='default'>Terraform</Button>
            </form>
        </Form>
    );
}
export default PlanetNftGenForm;