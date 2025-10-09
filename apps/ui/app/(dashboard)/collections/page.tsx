import CollectionList from "@/components/collection-list";

export default function page() {
    return (
        <div className="container mx-auto p-4">
            <h1 className="font-russo before:inline-block before:w-1 before:h-[calc(1rem+2px)] before:bg-indigo-500 before:mr-1.5 before:relative text-2xl">Collections</h1>
            <p className="text-xs text-gray-400">You can only mint new NFTs from active collections</p>
            <div className="mt-8">
                <CollectionList />
            </div>
        </div>
    )
}