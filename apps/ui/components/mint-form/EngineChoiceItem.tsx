import { cn } from "@/lib/utils";
import { CheckCircle2, Circle } from "lucide-react";

interface Engine {
    id: string;
    name: string;
    icon: string;
    state: string;
    message: string;
    address: string;
}


interface Props {
    isActive: boolean
    engine: Engine,
    onChange: (e: Engine) => void
}

export default function EngineChoiceItem({ engine, isActive, onChange }: Props) {
    return (
        <div onClick={() => { if (engine.state === 'active') onChange(engine) }} key={engine.id} className={cn("bg-white aspect-square rounded relative cursor-pointer overflow-hidden", { 'bg-gray-800': engine.state === 'pending' })}>
            {
                isActive ? <CheckCircle2 className={"fill-indigo-500 absolute top-[8px] right-[8px]"} /> : <Circle size={'1.28em'} className={"text-gray-500 absolute top-2.5 right-2.5"} />
            }
            <div className=" flex flex-col w-full h-full items-center justify-center p-3">
                <p className={cn("font-medium text-lg text-gray-800", { 'text-white': engine.state === 'pending' })}>{engine.name}</p>
                {engine.state === 'active' && (
                    <div className="flex items-baseline gap-1">
                        <p className="text-sm text-green-600">Now minting</p>
                        <span className="relative flex size-2">
                            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-600 opacity-75"></span>
                            <span className="relative inline-flex size-2 rounded-full bg-green-500"></span>
                        </span>
                    </div>
                )}

                {engine.state === 'pending' && (
                    <>
                        {/* <p className="text-xs font-medium bg-amber-50 text-gray-400 absolute -rotate-45 top-8 right-23 whitespace-nowrap px-5">COMING SOON</p> */}
                        <div className="flex items-baseline gap-1">
                            <p className="text-sm text-gray-500">Releasing in 5 days</p>
                        </div>
                    </>
                )}
            </div>
        </div>
    )

}