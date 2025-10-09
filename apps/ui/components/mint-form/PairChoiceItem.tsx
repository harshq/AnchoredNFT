import { CheckCircle2, Circle } from "lucide-react";

interface Pair {
    id: string;
    name: string;
    token1: {
        symbol: string;
        address: string;
        name: string;
        decimals: number;
    };
    token2: {
        symbol: string;
        address: string;
        name: string;
        decimals: number;
    }
}

interface Props {
    isActive: boolean
    pair: Pair
    onChange: (p: Pair) => void
}


export default function PairChoiceItem({ isActive, pair, onChange }: Props) {
    return (
        <div onClick={() => onChange(pair)} key={pair.id} className="bg-white aspect-square rounded relative cursor-pointer">
            {
                isActive ? <CheckCircle2 className={"fill-indigo-500 absolute top-[8px] right-[8px]"} /> : <Circle size={'1.28em'} className={"text-gray-500 absolute top-2.5 right-2.5"} />
            }
            <div className="text-gray-800 flex flex-col w-full h-full items-center justify-center p-3">
                <p className="font-medium text-lg">{pair.name}</p>
                <span className="text-xs text-center text-gray-400">Your deposit has to be in {pair.token1.name}</span>
            </div>
        </div>
    )
}