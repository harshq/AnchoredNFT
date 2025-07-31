import { ItemListed } from "../queries/listing";

export interface Attribute {
  trait_type: string;
  value: string;
}

export interface Metadata {
  attributes: Attribute[];
  description: string;
  image: string;
  name: string;
}

export type MetadataPlus = Metadata & {
  tokenAddress?: string | null;
  tokenId?: string | null;
};

export type MetadataMerged = MetadataPlus & ItemListed;
