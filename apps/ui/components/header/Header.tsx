import Image from 'next/image';
import {
    Breadcrumb,
    BreadcrumbItem,
    BreadcrumbLink,
    BreadcrumbList,
    BreadcrumbSeparator,
} from "@/components/ui/breadcrumb"
import { ConnectButton } from '@rainbow-me/rainbowkit';
import ListNftDialog from '../list-nft-dialog';
import PlanetNftGenDialog from "../planet-nft-gen-dialog";

const Header = () => {
    return (
        <header className="relative w-full">
            <Image priority src={'/bg-header.svg'} alt='hero background image' fill className='object-cover -z-10 object-right' />
            <div className='container flex justify-end mx-auto py-3 '>
                <div className='flex items-center gap-2'>
                    <PlanetNftGenDialog />
                    <ListNftDialog />
                    <ConnectButton />
                </div>
            </div>
            <div className='h-40 flex justify-center items-center flex-col'>
                <h2 className='text-center font-bold text-4xl text-white mb-2'>Explore NFTs</h2>
                <Breadcrumb>
                    <BreadcrumbList>
                        <BreadcrumbItem>
                            <BreadcrumbLink className='text-stone-300 hover:text-stone-300 font-light' >Home</BreadcrumbLink>
                        </BreadcrumbItem>
                        <BreadcrumbSeparator />
                        <BreadcrumbItem>
                            <BreadcrumbLink className='text-white hover:text-white'>Explore</BreadcrumbLink>
                        </BreadcrumbItem>
                    </BreadcrumbList>
                </Breadcrumb>
            </div>
        </header>
    );
}

export default Header;