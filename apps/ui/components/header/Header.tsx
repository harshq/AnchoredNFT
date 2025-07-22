import { ConnectButton } from '@rainbow-me/rainbowkit';
import ListNftDialog from '../list-nft-dialog';
import PlanetNftGenDialog from "../planet-nft-gen-dialog";

const Header = () => {
    return (
        <header className='p-3 bg-gradient-to-r from-sky-800 to-sky-700 border-b-2 border-b-sky-900 min-h-[67px]'>
            <div className='container flex justify-end mx-auto'>
                <div className='flex items-center gap-2'>
                    <PlanetNftGenDialog />
                    <ListNftDialog />
                    <ConnectButton />
                </div>
            </div>
        </header>
    );
}

export default Header;