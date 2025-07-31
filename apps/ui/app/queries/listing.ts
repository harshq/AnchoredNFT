import { QueryClient, useQuery, useSuspenseQuery } from "@tanstack/react-query";
import { BASE_PATH } from "@/app/constants/api";

const ACTIVE_LISTING_KEY = ["active-listings"];

export interface ItemListed {
  rindexer_id: number;
  contract_address: string;
  token_address?: string | null;
  token_id?: string | null;
  tx_hash: string;
  block_number: string;
  block_hash: string;
  network: string;
  tx_index: string;
  log_index: string;
  price?: string | null;
}

export const fetchActiveListings = async () => {
  const resp = await fetch(`${BASE_PATH}/api/v1/listing/active`, {
    next: {
      revalidate: 0,
    },
  });
  if (!resp.ok) throw new Error("Failed to fetch active listings");
  return await resp.json();
};

export const prefetchActiveListings = (queryClient: QueryClient) => {
  return queryClient.prefetchQuery<ItemListed[]>({
    queryKey: ACTIVE_LISTING_KEY,
    queryFn: fetchActiveListings,
  });
};

export const useActiveListing = () => {
  return useSuspenseQuery<ItemListed[]>({
    queryKey: ACTIVE_LISTING_KEY,
    queryFn: fetchActiveListings,
  });
};
