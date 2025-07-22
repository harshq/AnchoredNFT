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
import { FormInput } from 'lucide-react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';


const PlanetNftGenForm = () => {

    const form = useForm<z.infer<typeof schema>>({
        mode: 'all',
        resolver: zodResolver(schema),
        defaultValues: {

        }
    });

    const onSubmit = (params: z.infer<typeof schema>) => {
        console.log("HELLO", params);
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