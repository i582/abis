# TON ABI Catalog

This repository contains curated TON ABI data for protocol and contract families.

Current catalog size: **203 contract entries**.

Each curated project group normally includes:

- `info.toml` with catalog metadata, contract entries, known hashes, known addresses, and source links.
- Tolk ABI interface files under `types/` or `<contract>/types/`.
- Generated Acton wrappers when a code fixture or buildable target is available.
- Acton tests, preferably pinned fork storage/getter tests and real message-body BoC tests.
- `testdata/` fixtures when repeatable code/data BoCs are available.

## Covered Projects

### Core TON Standards And Interfaces

| Project | Coverage | Contract entries |
| --- | --- | --- |
| TON System | Official masterchain Elector and Config contracts for validator elections, stake recovery, network configuration, validator-set installation, and config proposal voting. | `Elector`, `Config` |
| Acton Testing | Built-in testing treasury contract used by Acton and TON Sandbox test environments. | `TreasuryContract` |
| Wallets | Standard wallet generations, highload wallets, vesting/lockup wallets, preprocessed wallet, and multisig v2. | `WalletV1r1`, `WalletV1r2`, `WalletV1r3`, `WalletV2r1`, `WalletV2r2`, `WalletV3r1`, `WalletV3r2`, `WalletV4r1`, `WalletV4r2`, `WalletV5r1`, `WalletHighloadV1r1`, `WalletHighloadV1r2`, `WalletHighloadV2`, `WalletHighloadV2r1`, `WalletHighloadV2r2`, `WalletHighloadV3r1`, `WalletPreprocessedV2`, `WalletVesting`, `LockupUniversal`, `LockupVesting`, `MultisigV2`, `MultisigOrderV2` |
| Jettons | TEP-74, TEP-89, stablecoin, Notcoin, mintless, Jetton 2.0, and Scaled UI jetton interfaces. | `JettonV1Master`, `JettonV100Master`, `JettonV1Wallet`, `DiscoverableJettonMaster`, `DiscoverableJettonWallet`, `JettonDiscovery`, `StablecoinMaster`, `StablecoinWallet`, `JettonNotcoinMaster`, `JettonNotcoinWallet`, `Jetton2Master`, `Jetton2Wallet`, `MintlessJettonMaster`, `MintlessJettonWallet`, `ScaledUiJettonMaster` |
| pTON | pTON v2.1 proxy TON minter and wallet contracts. | `PtonMinterV2`, `PtonWalletV2` |
| NFTs | TEP-62, TEP-64, TEP-66, and Getgems NFT v2 collection/item variants. | `NftV1Collection`, `NftV1Item`, `NftV1EditableItem`, `NftV2Collection`, `NftV2Item`, `NftV2EditableItem`, `GetgemsNftCollectionV2`, `GetgemsNftItemV2`, `GetgemsNftEditableItemV2` |
| SBTs | TEP-85 SBT item contracts. | `SbtV1Item`, `SbtV1Single` |
| TON DNS | TON DNS root resolver, `.ton` collection resolver, and `.ton` domain item contracts. | `DnsRootResolver`, `DnsCollection`, `DnsDomainItem` |
| TON Storage | TON Storage provider and per-file storage agreement contracts. | `StorageProvider`, `StorageContract` |

### DEX, AMM, And Trading Protocols

| Project | Coverage | Contract entries |
| --- | --- | --- |
| STON.fi | DEX core v1 router, pool, LP account, LP wallet, plus v2 router, pool variants, LP account, LP wallet, and vault. | `StonfiRouterV1`, `StonfiPoolV1`, `StonfiLpAccountV1`, `StonfiLpWalletV1`, `StonfiRouterV2`, `StonfiPoolV2ConstProduct`, `StonfiPoolV2Stableswap`, `StonfiPoolV2WeightedStableswap`, `StonfiPoolV2WeightedConstProduct`, `StonfiLpAccountV2`, `StonfiLpWalletV2`, `StonfiVaultV2` |
| DeDust | Protocol v1 factory, native vault, jetton vault, pool, liquidity deposit, v2 core contracts, separately curated library-backed CPMM pool family, and Uranus v3 launchpad contracts. | `DedustFactoryV1`, `DedustVaultNativeV1`, `DedustVaultJettonV1`, `DedustPoolV1`, `DedustLiquidityDepositV1`, `DedustFactoryV2`, `DedustVaultNativeV2`, `DedustVaultJettonV2`, `DedustPoolV2`, `DedustLiquidityDepositV2`, `DedustV2Cpmm`, `DedustUranusFactoryV3`, `DedustUranusMemeV3`, `DedustUranusMemeWalletV3` |
| Coffee Swap | DEX factory/init, vaults, pool variants, pool creator, liquidity depository, LP wallet, staking, CrossDex, and MEV Protector. | `CoffeeFactory`, `CoffeeInit`, `CoffeeVaultNative`, `CoffeeVaultJetton`, `CoffeeVaultExtra`, `CoffeePoolConstantProduct`, `CoffeePoolCurveFiStable`, `CoffeePoolCreator`, `CoffeeLiquidityDepository`, `JettonWalletCoffeeLp`, `CoffeeStakingMaster`, `CoffeeStakingVault`, `CoffeeStakingItem`, `CoffeeCrossDex`, `CoffeeMevProtector` |
| TONCO | Router, pool, account, pool factory, and position NFT. | `Router`, `Pool`, `Account`, `PoolFactory`, `PositionNFT` |
| Bidask | DLMM/DAMM pool factory, pool, range, LP multitoken, internal liquidity vault, DAMM pool, and DAMM LP wallet. | `BidaskPoolFactory`, `BidaskPool`, `BidaskRange`, `BidaskLpMultitoken`, `BidaskInternalLiquidityVault`, `BidaskDammPool`, `BidaskDammLpWallet` |
| Storm Trade | Perpetual DEX vaults, vAMMs, smart accounts, factory, position manager, referral/executor collections and items, prelaunch, LP minter/wallet, and proxy sender. | `StormVault`, `StormVaultNative`, `StormVamm`, `StormVammCoinm`, `SmartAccount`, `SmartAccountBlank`, `SmartAccountFactory`, `StormPositionManager`, `StormReferral`, `StormReferralCollection`, `StormExecutor`, `StormExecutorCollection`, `StormPrelaunch`, `StormLpMinter`, `StormLpWallet`, `StormProxySender` |

### Staking And Validator Protocols

| Project | Coverage | Contract entries |
| --- | --- | --- |
| Tonstakers | Staking pool, validator controller, tsTON jetton minter/wallet, and payout NFT collection/item. | `TonstakersPool`, `TonstakersValidatorController`, `TsTonMinter`, `TsTonWallet`, `TonstakersPayoutCollection`, `TonstakersPayoutItem` |
| Stakee | Staking pool, validator controller, STAKEED jetton minter/wallet, and payout NFT collection/item. | `StakeePool`, `StakeeValidatorController`, `StakeedMinter`, `StakeedWallet`, `StakeePayoutCollection`, `StakeePayoutItem` |
| Hipo Finance | hTON treasury, parent, wallet, bill collection/item, loan, and librarian. | `HipoTreasury`, `HipoParent`, `HipoWallet`, `HipoCollection`, `HipoBill`, `HipoLoan`, `HipoLibrarian` |
| Bemo | Bemo v2 financial jetton master and unstake request contracts. | `BemoFinancial`, `BemoUnstakeRequest` |
| Ton Whales Nominators | Nominator pool and proxy contracts for pooled TON staking through Elector. | `WhalesPool`, `WhalesProxy` |
| TON Validators Nominator Pool | Validator-managed TON nominator pool. | `NominatorPool` |
| Orbs Single Nominator | Simple/Single Nominator Pool v1.0 and v1.1 contracts for one owner and one validator wallet. | `SingleNominatorV10`, `SingleNominatorV11` |

### Lending, Vaults, And DeFi Applications

| Project | Coverage | Contract entries |
| --- | --- | --- |
| EVAA | Lending protocol master and user contracts, including Pyth and classic master variants. | `EvaaMasterPyth`, `EvaaMasterClassic`, `EvaaUser`, `EvaaBlank` |
| Aqua Protocol | Aqua USD master vault and jetton master interface. | `AquaUsdMasterVault` |
| Pyth Oracle | Pyth price oracle contract for feed updates, governance state, guardian sets, and price getters. | `PythOracle` |
| Affluent | Pools, accounts, batch, multiply vaults, lending vaults, and FactorialTON jetton contracts. | `Pool`, `Account`, `Batch`, `MultiplyVault`, `MultiplyVaultV2`, `LendingVault`, `FactorialTonMinter`, `FactorialTonWallet` |
| Locker | Locker and locker bill contracts. | `Locker`, `LockerBill` |

### Marketplaces, NFT Apps, And Distribution

| Project | Coverage | Contract entries |
| --- | --- | --- |
| Getgems | Deployer, marketplace, sale, auction, offer, raffle, and swap contracts. | `GetgemsDeployer`, `GetgemsNftAuctionV1`, `GetgemsNftAuctionV2`, `GetgemsNftAuctionV3R2`, `GetgemsNftAuctionV3R3`, `GetgemsNftAuctionV4R1`, `GetgemsNftFixpriceSaleV1`, `GetgemsNftSaleLegacy`, `GetgemsNftFixpriceSaleV2`, `GetgemsNftFixpriceSaleV3`, `GetgemsNftFixpriceSaleV3R2`, `GetgemsNftFixpriceSaleV3R3`, `GetgemsNftFixpriceSaleV4R1`, `GetgemsNftMarketplaceV1`, `GetgemsNftMarketplaceV2`, `GetgemsNftOfferV1`, `GetgemsNftOfferV1R3`, `GetgemsNftRaffle`, `GetgemsNftSwap` |
| TeleMint | Telegram TeleMint NFT item contract used by Fragment username and anonymous-number NFTs. | `TelemintNftItem` |
| Fragment | Telegram username and anonymous-number collection/item contracts, plus MarketApp/Fragment buy-routing proxy variants for Telegram collectible purchases. | `FragmentUsernameCollection`, `FragmentNumbersCollection`, `FragmentUsernameItem`, `FragmentNumbersItem`, `FragmentMarketappProxyKnown`, `FragmentMarketappProxySimple`, `FragmentMarketappProxyJetton` |
| Airdrop Interlocker | Airdrop claim interlocker contracts. | `AirdropInterlockerV1`, `AirdropInterlockerV2` |

### Payments, Automation, And Wallet Tooling

| Project | Coverage | Contract entries |
| --- | --- | --- |
| Invoices | Payload-only invoice body ABI for TON and Jetton payment payloads. | `InvoicesPayloadInterface` |
| Tonkeeper Subscriptions | Subscription V1 and V2 wallet/plugin contracts. | `SubscriptionV1`, `SubscriptionV2` |
| TON Cron | Cron interface implementations with `get_cron_info` and `cron_trigger` external bodies. | `Cron` |
| Tonkeeper 2FA | Tonkeeper 2FA wallet extension contract. | `Tonkeeper2fa` |
