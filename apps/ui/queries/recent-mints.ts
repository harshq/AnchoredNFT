import { gql, TypedDocumentNode } from "@apollo/client";

export const RECENT_MINTS: TypedDocumentNode<RecentMintsType> = gql`
  query MyQuery($engine: String!) {
    Token(
      where: {
        isDeleted: { _eq: false }
        metadata: { attributes: { engine: { _eq: $engine } } }
      }
    ) {
      id
      minter
      owner
      tokenId
      metadata {
        description
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

export const MY_RECENT_MINTS: TypedDocumentNode<RecentMintsType> = gql`
  query MyQuery($address: String!) {
    Token(where: { isDeleted: { _eq: false }, minter: { _eq: $address } }) {
      id
      minter
      owner
      tokenId
      metadata {
        description
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
  Token: {
    owner: string;
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
