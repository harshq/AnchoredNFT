import { gql, TypedDocumentNode } from "@apollo/client";

export const RECENT_MINTS: TypedDocumentNode<RecentMintsType> = gql`
  query MyQuery($engine: String!) {
    AnchoredNFT_NFTMinted(
      where: { metadata: { attributes: { engine: { _eq: $engine } } } }
    ) {
      minter
      requestId
      tokenId
      metadata {
        name
        image
        attributes {
          amount
          collateral
          engine
          pair
        }
      }
    }
  }
`;

export const MY_RECENT_MINTS: TypedDocumentNode<RecentMintsType> = gql`
  query MyQuery($address: String!) {
    AnchoredNFT_NFTMinted(where: { minter: { _eq: $address } }) {
      id
      minter
      tokenId
      metadata {
        description
        id
        image
        name
        attributes {
          amount
          collateral
          engine
          pair
        }
      }
    }
  }
`;

export type RecentMintsType = {
  AnchoredNFT_NFTMinted: {
    minter: string;
    requestId: string; // BigInt in GraphQL → string in JS
    tokenId: string; // same as above
    metadata: {
      name: string;
      image: string;
      attributes: {
        amount: string;
        collateral: string;
        engine: string;
        pair: string;
      };
    };
  }[];
};
