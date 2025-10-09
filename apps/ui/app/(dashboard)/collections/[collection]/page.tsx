import Link from 'next/link'
import { Button } from "@/components/ui/button";
import RecentMintCard from "@/components/recent-mint-card";
import collections from "@/data/collections.json";
import leaderboard from "@/data/leaderboard.json";
import recents from "@/data/recent-mints.json";

export default async function Page({
    params
}: { params: Promise<{ collection: string }> }) {
    const resolvedParams = await params;
    const collectionData = collections.data.filter(col => col.url === `/collections/${resolvedParams.collection}`)[0];
    return (
        <div className="container mx-auto p-4">
            <h1 className="font-russo before:inline-block before:w-1 before:h-[calc(1rem+2px)] before:bg-indigo-500 before:mr-1.5 before:relative text-2xl">{collectionData.name}</h1>
            <p className="text-xs text-gray-400">{collectionData.sub}</p>

            <div className="mt-8 w-full h-30 bg-gradient-to-r from-purple-100 to-cyan-200 rounded flex items-center justify-center">
                <Link href={`/collections/${resolvedParams.collection}/mint`}>
                    <Button className='bg-indigo-500 hover:bg-indigo-600 cursor-pointer'>
                        {`Mint your own ${collectionData.name}`}
                    </Button>
                </Link>
            </div>

            <div className="mt-8 grid grid-cols-1 md:grid-cols-[1fr_250px] gap-6 h-100">
                <div>
                    <h3 className="font-russo before:inline-block before:w-1 before:h-[calc(1rem-3px)] before:bg-indigo-500 before:mr-1.5 before:relative">Recent Mints</h3>
                    <p className="text-xs text-gray-400">Recently minted NFTs in this collection</p>

                    <div className="mt-8 grid grid-cols-2  xl:grid-cols-3 gap-1.5">
                        {
                            recents.data.map(token => <RecentMintCard key={token.name} {...token} />)
                        }
                    </div>
                </div>
                <div>
                    <h3 className="font-russo before:inline-block before:w-1 before:h-[calc(1rem-3px)] before:bg-indigo-500 before:mr-1.5 before:relative">Leaderboard</h3>
                    <p className="text-xs text-gray-400">By total locked value (TLV)</p>
                    <ul className="mt-8 space-y-4">
                        {
                            leaderboard.data.map((user, index) => (
                                <li key={user.address} className="flex">
                                    <div className="rounded-full bg-indigo-800 size-7 text-xs shrink-0 flex items-center justify-center font-bold">{index + 1}</div>
                                    <div className="truncate text-xs ml-2">
                                        <span className="">{user.address}</span>
                                        <div className="flex text-gray-500">
                                            {user.tokenCount} NFTs | {`${user.tlv.currencySign}${user.tlv.amount}`} locked
                                        </div>
                                    </div>
                                </li>
                            ))
                        }
                    </ul>

                </div>
            </div>



        </div>
    );
}