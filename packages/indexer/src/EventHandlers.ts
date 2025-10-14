/*
 * Please refer to https://docs.envio.dev for a thorough guide on all Envio indexer features
 */
import {
  AnchoredNFT,
  AnchoredNFT_Approval,
  AnchoredNFT_ApprovalForAll,
  AnchoredNFT_CoordinatorSet,
  AnchoredNFT_EngineAdded,
  AnchoredNFT_EngineStateChanged,
  AnchoredNFT_NFTDestroyed,
  AnchoredNFT_NFTMinted,
  AnchoredNFT_NFTRequested,
  AnchoredNFT_OwnershipTransferRequested,
  AnchoredNFT_OwnershipTransferred,
  AnchoredNFT_Transfer,
} from "generated";
import { getGeneratedByChainId } from "generated/src/ConfigYAML.gen";
import { S, experimental_createEffect } from "envio";
import { createPublicClient, http, Address } from "viem";
import { anvil } from "viem/chains";
import anchoredAbi from "../abi/AnchoredNFT.json";
import { decodeBase64ToJson } from "./utils/base64Helper";
import type { TokenMetadata } from "./types/Token";

const client = createPublicClient({
  chain: anvil,
  transport: http("http://127.0.0.1:8545", { batch: true }),
});

const getTokenMetadata = experimental_createEffect(
  {
    name: "getMetadata",
    input: { chainId: S.number, tokenId: S.bigint },
    output: {
      id: S.bigint,
      name: S.string,
      description: S.string,
      image: S.string,
      attributes: {
        engine: S.optional(S.string),
        pair: S.optional(S.string),
        collateral: S.optional(S.string),
        amount: S.optional(S.string),
      },
    },
    // cache: true,
  },
  async ({ input }) => {
    const config = getGeneratedByChainId(input.chainId);
    const contract = config.contracts["AnchoredNFT"];

    const encoded = await client.readContract({
      address: contract.addresses[0] as Address,
      abi: anchoredAbi,
      functionName: "tokenURI",
      args: [input.tokenId],
    });

    const metadata = decodeBase64ToJson<TokenMetadata>(encoded as string);
    return {
      id: input.tokenId,
      name: metadata.name,
      description: metadata.description,
      image: metadata.image,
      attributes: {
        engine: metadata.attributes.find((a) => a.trait_type === "Engine")
          ?.value,
        pair: metadata.attributes.find((a) => a.trait_type === "Synced Pair")
          ?.value,
        collateral: metadata.attributes.find(
          (a) => a.trait_type === "Collateral Token"
        )?.value,
        amount: metadata.attributes.find(
          (a) => a.trait_type === "Collateral Amount"
        )?.value,
      },
    };
  }
);

AnchoredNFT.Approval.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_Approval = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    owner: event.params.owner,
    approved: event.params.approved,
    tokenId: event.params.tokenId,
  };

  context.AnchoredNFT_Approval.set(entity);
});

AnchoredNFT.ApprovalForAll.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_ApprovalForAll = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    owner: event.params.owner,
    operator: event.params.operator,
    approved: event.params.approved,
  };

  context.AnchoredNFT_ApprovalForAll.set(entity);
});

AnchoredNFT.CoordinatorSet.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_CoordinatorSet = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    vrfCoordinator: event.params.vrfCoordinator,
  };

  context.AnchoredNFT_CoordinatorSet.set(entity);
});

AnchoredNFT.EngineAdded.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_EngineAdded = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    engine: event.params.engine,
  };

  context.AnchoredNFT_EngineAdded.set(entity);
});

AnchoredNFT.EngineStateChanged.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_EngineStateChanged = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    engine: event.params.engine,
    newState: event.params.newState,
  };

  context.AnchoredNFT_EngineStateChanged.set(entity);
});

AnchoredNFT.NFTDestroyed.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_NFTDestroyed = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    tokenId: event.params.tokenId,
    owner: event.params.owner,
  };

  context.AnchoredNFT_NFTDestroyed.set(entity);

  const token = await context.Token.get(event.params.tokenId.toString());
  if (token) {
    context.Token.set({
      ...token,
      isDeleted: true,
    });
  }
});

AnchoredNFT.NFTMinted.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_NFTMinted = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    requestId: event.params.requestId,
    tokenId: event.params.tokenId,
    minter: event.params.minter,
  };

  context.AnchoredNFT_NFTMinted.set(entity);

  const metadata = await context.effect(getTokenMetadata, {
    chainId: event.chainId,
    tokenId: event.params.tokenId,
  });

  context.Attribute.set({
    id: event.params.tokenId.toString(),
    engine: metadata.attributes.engine!,
    pair: metadata.attributes.pair!,
    collateral: metadata.attributes.collateral!,
    amount: metadata.attributes.amount!,
  });

  context.Metadata.set({
    id: event.params.tokenId.toString(),
    name: metadata.name,
    description: metadata.description,
    image: metadata.image,
    attributes_id: event.params.tokenId.toString(),
  });

  context.Token.set({
    id: event.params.tokenId.toString(),
    requestId: event.params.requestId,
    tokenId: event.params.tokenId,
    minter: event.params.minter,
    isDeleted: false,
    owner: event.params.minter,
    metadata_id: event.params.tokenId.toString(),
  });
});

AnchoredNFT.NFTRequested.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_NFTRequested = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    requestId: event.params.requestId,
    tokenId: event.params.tokenId,
    collateralTokenAddress: event.params.collateralTokenAddress,
    collateralAmount: event.params.collateralAmount,
    minter: event.params.minter,
  };

  context.AnchoredNFT_NFTRequested.set(entity);
});

AnchoredNFT.OwnershipTransferRequested.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_OwnershipTransferRequested = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    from: event.params.from,
    to: event.params.to,
  };

  context.AnchoredNFT_OwnershipTransferRequested.set(entity);
});

AnchoredNFT.OwnershipTransferred.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_OwnershipTransferred = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    from: event.params.from,
    to: event.params.to,
  };

  context.AnchoredNFT_OwnershipTransferred.set(entity);
});

AnchoredNFT.Transfer.handler(async ({ event, context }) => {
  const entity: AnchoredNFT_Transfer = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    from: event.params.from,
    to: event.params.to,
    tokenId: event.params.tokenId,
  };

  context.AnchoredNFT_Transfer.set(entity);
});
