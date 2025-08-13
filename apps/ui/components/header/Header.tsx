import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';

import ListNftDialog from '../list-nft-dialog';
import HeaderBreadcrumbs from './HeaderBreadcrumbs';
import { Button } from '../ui/button';

interface Props {
    title: string
}

const Header = ({ title }: Props) => {
    return (
        <header className="relative w-full bg-radial from-1% from-sky-950 to-60% to-gray-950">
            <div className='container flex justify-end mx-auto py-3 '>
                <div className='flex items-center gap-2'>
                    <Link href={'/explore'}>
                        <Button className='bg-blue-600 hover:bg-blue-800 font-bold text-md'>
                            Explore
                        </Button>
                    </Link>
                    <Link href={'/terraform'}>
                        <Button className='bg-blue-600 hover:bg-blue-800 font-bold text-md'>
                            Terraform Planet
                        </Button>
                    </Link>
                    <ListNftDialog trigger={
                        <Button className='bg-blue-600 hover:bg-blue-800 font-bold text-md'>
                            Sell NFT
                        </Button>
                    } />
                    <ConnectButton />
                </div>
            </div>
            <div className='h-40 flex justify-center items-center flex-col'>
                <h2 className='text-center font-bold text-4xl text-white mb-2'>{title}</h2>
                <HeaderBreadcrumbs />
            </div>
        </header>
    );
}

export default Header;