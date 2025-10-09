## Foundry

== Return ==
0: contract AnchoredNFT 0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1
1: contract PlanetEngineV1 0x0B306BF915C4d645ff596e518fAf3F9669b97016
2: contract NFTMarketplace 0xc6e7DF5E7b4f2A278906862b61205850344D4e7d
3: contract Vault 0x9A676e781A523b5d0C0e43731313A708CB607508
4: struct Config Config({ account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, paymentToken: 0x0165878A594ca255338adfa4d48449f69242Eb8F, linkToken: 0x610178dA211FEF7D417bC0e6FeD39F05609AD788, vrfCoordinator: 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e, vrfCoordinatorSubId: 87250072816304088438624783400922122886583355759606152882453986521749351772382 [8.725e76], vrfKeyHash: 0x111122223333444455556666777788889999aaaabbbbccccddddeeeeffff0000, vrfGasLimit: 500000 [5e5], collateralPairs: ["BTC/USD", "ETH/USD"], collateralBases: [0x0165878A594ca255338adfa4d48449f69242Eb8F, 0x0165878A594ca255338adfa4d48449f69242Eb8F], collateralTokens: [0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9, 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0], collateralUniswapV3Pools: [0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6, 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318] })

== Logs ==
wBTC mock deployed at 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
wETH mock deployed at 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
USDT mock deployed at 0x0165878A594ca255338adfa4d48449f69242Eb8F
LINK token mock deployed at 0x610178dA211FEF7D417bC0e6FeD39F05609AD788
VRFCoordinator deployed at 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e
Funding VRF subscription ID: 87250072816304088438624783400922122886583355759606152882453986521749351772382

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
