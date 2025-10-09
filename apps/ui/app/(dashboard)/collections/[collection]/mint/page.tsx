import MintForm from "@/components/mint-form";

export default async function Page() {
    return (
        <div className="container mx-auto p-4 relative">
            <h2 className="font-russo text-2xl text-center mt-15">Let's mint your own NFT</h2>
            <div className="flex items-center justify-center">
                <MintForm />
            </div>
        </div>
    )

}