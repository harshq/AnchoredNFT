"use client"
import { ConnectButton } from '@rainbow-me/rainbowkit';
import React from 'react'
import { Button } from '../ui/button';
import { Wallet, TriangleAlert, Loader } from 'lucide-react';

const ConnectWallet: React.FC = () => {
    const [isLoading, setIsLoading] = React.useState(true);
    React.useEffect(() => {
        setTimeout(() => {
            setIsLoading(false)
        }, 800);
    }, [setIsLoading])
    return (
        <div className='relative'>
            {
                isLoading && (
                    <div className='absolute top-0 right-0 left-0 bottom-0 bg-indigo-600 rounded flex items-center justify-center text-white/60'>
                        <Loader className='animate-spin-slow' size={20} />
                    </div>
                )
            }

            <ConnectButton.Custom>
                {({
                    account,
                    chain,
                    openAccountModal,
                    openChainModal,
                    openConnectModal,
                    authenticationStatus,
                    mounted,
                }) => {
                    // Note: If your app doesn't use authentication, you
                    // can remove all 'authenticationStatus' checks
                    const ready = mounted && authenticationStatus !== 'loading';
                    const connected =
                        ready &&
                        account &&
                        chain &&
                        (!authenticationStatus ||
                            authenticationStatus === 'authenticated');

                    return (
                        <div
                            {...(!ready && {
                                'aria-hidden': true,
                                'style': {
                                    opacity: 0,
                                    pointerEvents: 'none',
                                    userSelect: 'none',
                                },
                            })}
                        >
                            {(() => {
                                if (!connected) {
                                    return (
                                        <Button className='w-full py-[21px] bg-indigo-600 hover:bg-indigo-700 cursor-pointer text-xs font-bold' onClick={openConnectModal} type="button">
                                            <Wallet />
                                            Connect Wallet
                                        </Button>
                                    );
                                }

                                if (chain.unsupported) {
                                    return (
                                        <Button className='w-full bg-amber-800 hover:bg-amber-900 cursor-pointer h-[42] text-xs font-bold' onClick={openChainModal} type="button">
                                            <TriangleAlert />
                                            Unsupported Chain
                                        </Button>
                                    );
                                }

                                return (
                                    <div className='w-full p-0.5 rounded flex flex-col bg-indigo-600 items-start gap-y-0.5'>
                                        <Button
                                            className='cursor-pointer h-auto py-0 px-2 bg-transparent text-white/80 hover:bg-indigo-700'
                                            onClick={openChainModal}
                                            type="button"
                                        >
                                            {chain.name}
                                        </Button>
                                        <Button
                                            className='cursor-pointer h-auto py-0 px-2 bg-transparent text-xs font-bold hover:bg-indigo-700' onClick={openAccountModal} type="button">
                                            <span>{account.displayName}</span>
                                            <span className='hidden sm:block -ml-1'>{account.displayBalance
                                                ? ` (${account.displayBalance})`
                                                : ''}</span>
                                        </Button>
                                    </div>
                                );
                            })()}
                        </div>
                    );
                }}
            </ConnectButton.Custom>
        </div>
    );
}
export default ConnectWallet;