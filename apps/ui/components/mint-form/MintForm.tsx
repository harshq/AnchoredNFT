"use client";

import React from "react";
import { z } from "zod";
import { Resolver, useForm } from "react-hook-form";
import { ContractFunctionExecutionError, parseUnits, formatUnits } from "viem";
import Lottie from "lottie-react";
import { Loader } from "lucide-react";

import approvalAnimation from "@/public/animations/approval-animation.json";
import runAnimation from "@/public/animations/run-animation.json";

import { zodResolver } from "@/utils/ZodResolver";
import engines from "@/data/engines.json";
import pairs from "@/data/token-pairs.json";
import useERC20 from "@/hooks/useERC20";
import useAnchoredContract from "@/hooks/useAnchoredContract";

import { Button } from "../ui/button";
import { Form, FormControl, FormField, FormItem, FormMessage } from "../ui/form";
import ChoiceCard from "../choice-card";
import schema from "./schema";
import EngineChoiceItem from "./EngineChoiceItem";
import PairChoiceItem from "./PairChoiceItem";
import RecentMintCard from "../recent-mint-card";

import AmountInput from "./AmountInput";
import { useAccount, useBalance, useReadContract } from "wagmi";
import { decodeBase64ToJson } from "@/utils/base64Helper";
import { useConnectModal } from "@rainbow-me/rainbowkit";
import SuccessAnimation from "./SuccessAnimation";

type Step1Schema = z.infer<typeof schema["1"]>;
type Step2Schema = z.infer<typeof schema["2"]>;
type Step3Schema = z.infer<typeof schema["3"]>;

type FormValues = Step1Schema | Step2Schema | Step3Schema;

type FormData = Step1Schema & Partial<Step2Schema> & Partial<Step3Schema>

type RequestedEventData = {
    minter: string,
    requestId: bigint,
    tokenId: bigint
};

type TokenMeta = {
    name: string
    image: string
    description: string
    attributes: {
        trait_type: string
        value: string
    }[]
}

type Step = 1 | 2 | 3 | 4 | 5

const FORMSTATE = {
    SUBMITTING: 'submitting',
    COMPLETE: 'complete',
    FAILED: 'failed',
    IN_PROGRESS: 'in-progress'
} as const;

type FormState = typeof FORMSTATE[keyof typeof FORMSTATE]

export default function MintForm() {
    const account = useAccount();
    const { openConnectModal } = useConnectModal();
    const { approveFunds, checkbalance } = useERC20();
    const { getTokenUri, create, parseLogs, listenToEvent } = useAnchoredContract();

    const [isSubmitting, setIsSubmitting] = React.useState(false)
    const [formState, setFormState] = React.useState<FormState>(FORMSTATE.IN_PROGRESS);
    const [tokenMetaData, setTokenMetadata] = React.useState<TokenMeta | null>(null)

    const requestedEventDataRef = React.useRef<RequestedEventData | null>(null)

    const [step, setStep] = React.useState<Step>(1)
    const [formData, setFormData] = React.useState<FormData>({
        // step-1
        engine: "",
        // step-2
        pair: "",
        collateralAddress: "",
        collateralDecimals: 0,
        // step-3
        collateralAmount: ""
    });

    const form = useForm<FormData>({
        mode: "onSubmit",
        resolver: zodResolver(schema[step]) as Resolver<FormData>,
    })

    React.useEffect(() => {
        form.reset(formData, {
            keepErrors: true
        });
    }, [step]);

    const handleSubmit = async (values: FormValues) => {
        if (!account.isConnected) {
            openConnectModal!();
            return;
        }

        setFormState(FORMSTATE.IN_PROGRESS);
        setFormData((prev) => ({ ...prev, ...values }));
        setIsSubmitting(true);


        if (step === 1) setStep(2);
        else if (step === 2) setStep(3);
        else if (step === 3 || step === 4) {
            if (step === 3) setStep(4);
            // Final submit action
            const data = { ...formData, ...values };
            const amount = parseUnits(data.collateralAmount!, data.collateralDecimals!)
            const balance = await checkbalance(data.collateralAddress!, account.address as string)

            if (balance <= amount) {
                form.setError("collateralAmount", {
                    message: "Connected account balance is insufficient"
                })
                setStep(3);
                setIsSubmitting(false);
                return;
            }


            // 1. Get the approval for funds
            try {
                await approveFunds(data.collateralAddress!, amount);
            } catch (error) {
                console.log(error)
                setFormState(FORMSTATE.FAILED);
                if (error instanceof ContractFunctionExecutionError) {
                    // TODO: handle metamask reject request
                }
            }

            // 2. Mint the NFT
            try {
                const resp = await create(data.engine, data.collateralAddress!, amount);
                setStep(5)
                const logs = await parseLogs('NFTRequested', resp.logs);
                const eventLog = logs.find((log) => (log as any).args!.minter === account.address);
                if (eventLog) {
                    const event = (eventLog as any);
                    requestedEventDataRef.current = {
                        minter: event.args.minter,
                        requestId: event.args.requestId,
                        tokenId: event.args.tokenId
                    };

                    const events = await listenToEvent(event.args.requestId, event.args.tokenId, event.args.minter);
                    const uri = await getTokenUri(event.args.tokenId);
                    const tokenMeta = decodeBase64ToJson(uri);
                    setTokenMetadata(tokenMeta);
                    setFormState(FORMSTATE.COMPLETE);
                }

            } catch (error) {
                setFormState(FORMSTATE.FAILED);
                if (error instanceof ContractFunctionExecutionError) {
                    // TODO: handle metamask reject request
                }
                console.log("ERROR!")
                console.log(error)
            }
        }

        setIsSubmitting(false);
    };

    const getFormTitle = (step: Step) => {
        switch (step) {
            case 1:
                return "Select an engine for your NFT";
            case 2:
                return `Select an token pair to sync with your NFT`
            case 3:
                return "Enter collateral amount you're depositing";
            case 4:
                return "Check metamask for fund approvals";
            case 5:
                return "Minting your NFT";
        }
    }


    const renderSubmitButton = (step: Step, disabled: boolean, formState: FormState) => {
        let buttonText: React.ReactNode
        if (step === 4 || step === 5) {
            buttonText = formState === FORMSTATE.FAILED ? 'Retry' : <Loader className="animate-spin" />
        } else if (step === 3) {
            buttonText = 'Mint'
        } else {
            buttonText = 'Next'
        }

        return (
            <Button
                type="submit"
                disabled={disabled}
                className="w-full bg-indigo-500 hover:bg-indigo-600 cursor-pointer font-medium"
            >
                {buttonText}
            </Button>
        )
    }

    if (formState === FORMSTATE.COMPLETE && tokenMetaData != null) {

        const syncedPairForToken = tokenMetaData.attributes.find(attr => attr.trait_type === "Synced Pair")!.value;
        const collateralAmount = tokenMetaData.attributes.find(a => a.trait_type === "Collateral Amount")!.value;
        const tokenEngine = tokenMetaData.attributes.find(a => a.trait_type === "Engine")!.value;
        const collateralInfo = pairs.data.find(pair => pair.name === syncedPairForToken)!;
        const collateralAmountFormatted = formatUnits(BigInt(collateralAmount), collateralInfo.token1.decimals);

        return (
            <>
                <SuccessAnimation />
                <div className="w-80 relative">
                    <p className="text-center text-sm text-gray-400 font-medium">Here's your NFT</p>
                    <div className="mt-5 ">
                        <RecentMintCard
                            imageUrl={tokenMetaData.image}
                            owner={account.address as string}
                            name={tokenMetaData.name}
                            collection={tokenEngine}
                            lockedValue={`${collateralAmountFormatted} ${collateralInfo.token1.symbol}`}
                            syncedPair={syncedPairForToken} />
                    </div>
                </div>
            </>
        )
    }

    return (
        <div className="w-full md:w-100">
            <p className="text-center text-sm text-gray-400 font-medium">{getFormTitle(step)}</p>
            <div className="mt-8">
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(handleSubmit)}>
                        {
                            step === 1 && (
                                <FormField
                                    control={form.control}
                                    name="engine"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormControl>
                                                <ChoiceCard
                                                    items={engines.data}
                                                    value={engines.data.find(engine => engine.address === field.value)}
                                                    onChange={(engine) => field.onChange(engine.address)}
                                                    renderItem={(engine, onChange, isActive) => <EngineChoiceItem key={engine.id} engine={engine} isActive={isActive} onChange={onChange} />}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            )
                        }
                        {
                            step === 2 && (
                                <FormField
                                    control={form.control}
                                    name="pair"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormControl>
                                                <ChoiceCard
                                                    items={pairs.data}
                                                    value={pairs.data.find(pair => pair.token1.address === field.value)}
                                                    onChange={(pair) => {
                                                        form.setValue("collateralAddress", pair.token1.address);
                                                        form.setValue("collateralDecimals", pair.token1.decimals);
                                                        field.onChange(pair.token1.address)
                                                    }}
                                                    renderItem={(pair, onChange, isActive) => <PairChoiceItem key={pair.id} pair={pair} isActive={isActive} onChange={onChange} />}
                                                />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            )
                        }
                        {
                            step === 3 && (
                                <FormField
                                    name="collateralAmount"
                                    control={form.control}
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormControl>
                                                <AmountInput {...field} decimals={form.getValues("collateralDecimals")!} />
                                            </FormControl>
                                            <div className="text-right">
                                                {
                                                    !!form.formState.errors.collateralAmount ? <FormMessage /> : <span className="text-xs text-gray-600">Enter amount upto {form.getValues("collateralDecimals")!} decimals</span>
                                                }
                                            </div>
                                        </FormItem>
                                    )}
                                />
                            )
                        }
                        {
                            step === 4 && (
                                <div className="px-15">
                                    <Lottie animationData={approvalAnimation} loop={true} />
                                </div>
                            )
                        }
                        {
                            step === 5 && (
                                <div className="px-15">
                                    <Lottie animationData={runAnimation} loop={true} />
                                </div>
                            )
                        }
                        <div className="mt-2 col-span-2">
                            {renderSubmitButton(step, isSubmitting, formState)}
                            <Button type="button" disabled={isSubmitting || step === 1} onClick={() => setStep((curr) => Math.max(1, curr - 1) as Step)} variant="link" className="text-white w-full cursor-pointer">Back</Button>
                        </div>
                    </form>
                </Form>
            </div>
        </div>
    )
}