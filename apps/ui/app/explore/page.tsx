import { dehydrate, HydrationBoundary, QueryClient } from "@tanstack/react-query";

import Header from "@/components/header";
import { prefetchActiveListings } from "../../queries/listing";
import ActiveListingGrid from "@/components/active-listing-grid";

export default async function Home() {
  const queryClient = new QueryClient();

  await prefetchActiveListings(queryClient);

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Header title="Explore NFTs" />
      <ActiveListingGrid />
      <div className="h-1000" />
    </HydrationBoundary>
  );
}
