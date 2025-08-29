## Foundry

```
== Return ==
4: struct Config Config({ account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, paymentToken: 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82, linkToken: 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e, vrfCoordinator: 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0, vrfCoordinatorSubId: 84043766784963433578723029829606828737321687816838903587363274629640531207394 [8.404e76], vrfKeyHash: 0x111122223333444455556666777788889999aaaabbbbccccddddeeeeffff0000, vrfGasLimit: 500000 [5e5], collateralPairs: ["BTC/USD", "ETH/USD"], collateralTokens: [0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9, 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318], collateralPriceFeeds: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512, 0x0165878A594ca255338adfa4d48449f69242Eb8F] })

== Logs ==
  wBTC mock deployed at 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
  wETH mock deployed at 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318
  USDT mock deployed at 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82
  LINK token mock deployed at 0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e
  VRFCoordinator deployed at 0xA51c1fc2f0D1a1b8494Ed1FE312d7C3a78Ed91C0
  Funding VRF subscription ID: 84043766784963433578723029829606828737321687816838903587363274629640531207394
  PlanetNFT is at 0x3Aa5ebB10DC797CAC828524e59A333d0A371443c
  NFTMarketplace is at 0x59b670e9fA9D0A427751Af201D676719a970857b
  Vault is at 0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE
  NFTEngine is at 0x68B1D87F95878fE05B998F19b66F4baba5De1aed
```

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
