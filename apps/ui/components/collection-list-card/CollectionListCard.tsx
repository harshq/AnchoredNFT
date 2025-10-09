import { cn } from "@/lib/utils";
import Image from "next/image";
import Link from "next/link";

export interface Props {
    id: number
    imageUrl: string
    name: string
    description: string
    ended: boolean
    url: string
}


export default function CollectionListCard({ name, description, imageUrl, ended, url }: Props) {
    return (
        <Link href={url}>
            <div className="border-1 border-gray-600/50 bg-white/10 rounded p-1 group/card">
                <div className=" rounded relative overflow-hidden w-full aspect-square">
                    <Image className={cn("group-hover/card:scale-110 transition-all", { 'grayscale': ended })} objectFit="cover" src={imageUrl} alt="collection cover photo" fill />
                </div>
                <div className="p-2 flex-3">
                    <div className="flex items-center gap-x-2">
                        <h3 className={cn("text-xl font-medium ", { 'text-green-500': !ended })}>{name}</h3>
                        {
                            !ended && (
                                <span className="relative flex size-2">
                                    <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-green-400 opacity-75"></span>
                                    <span className="relative inline-flex size-2 rounded-full bg-green-500"></span>
                                </span>
                            )
                        }
                    </div>
                    <p className="text-xs text-gray-500">
                        {
                            ended ? 'Mint ended' : 'Now minting'
                        }
                    </p>
                    <p className="line-clamp-3 text-xs text-gray-400 mt-4">{description}</p>
                </div>
            </div></Link>)
}