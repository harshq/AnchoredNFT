import Header from "@/components/header";
import { dehydrate, HydrationBoundary, QueryClient } from "@tanstack/react-query";
import { prefetchActiveListings } from "./queries/listing";
import ActiveListingGrid from "@/components/active-listing-grid";

export default async function Home() {
  const queryClient = new QueryClient();

  prefetchActiveListings(queryClient);

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Header />
      <ActiveListingGrid />
      <div className="h-1000" />
    </HydrationBoundary>
  );
}
