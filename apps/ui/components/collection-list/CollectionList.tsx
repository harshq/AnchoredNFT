import collections from "@/data/collections.json";
import CollectionListCard, { Props as CollectionCardProps } from "../collection-list-card";

export default function CollectionList() {
    return (
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-1">
            {
                collections.data.map(collection => <CollectionListCard key={collection.id} {...collection} />)
            }
        </div>
    );
}