# TON ABI Catalog

This repository contains curated TON ABI data for protocol and contract families.

Current catalog size: **273 contract entries**, **322 unique contract code hashes**, and **315 unique known contract addresses**.

Across the generated public catalog, the repository declares **1253 unique opcode prefixes** and **575 unique get-method names**.

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
| TON Verifier | On-chain source registry, verifier registry, and per-source verification records. | `VerifierSourcesRegistry`, `VerifierRegistry`, `VerifierSourceItem` |
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
| STON.fi | DEX core v1 router, pool, LP account, LP wallet, plus v2 router revisions, pool variants, LP account, LP wallet, vault, farming collection/NFT, and the Escrow Position, Factory, and Vault family. | `StonfiRouterV1`, `StonfiPoolV1`, `StonfiLpAccountV1`, `StonfiLpWalletV1`, `StonfiRouterV2`, `StonfiPoolV2ConstProduct`, `StonfiPoolV2Stableswap`, `StonfiPoolV2WeightedStableswap`, `StonfiPoolV2WeightedConstProduct`, `StonfiLpAccountV2`, `StonfiLpWalletV2`, `StonfiVaultV2`, `StonfiFarmCollection`, `StonfiFarmNft`, `StonfiEscrowPosition`, `StonfiEscrowFactory`, `StonfiEscrowVault` |
| Omniston | Standalone STON.fi Omniston Fee-Vault Minter for DeDust/Tonco referral-fee vault derivation, fee deposits, and payout routing. | `OmnistonFeeVault` |
| DeDust | Protocol v1 and v2 core contracts, both verified CPMM v2 pool revisions, x1000 wallet storage, and Uranus launchpad revisions. | `DedustFactoryV1`, `DedustVaultNativeV1`, `DedustVaultJettonV1`, `DedustPoolV1`, `DedustLiquidityDepositV1`, `DedustFactoryV2`, `DedustVaultNativeV2`, `DedustVaultJettonV2`, `DedustPoolV2`, `DedustLiquidityDepositV2`, `DedustV2Cpmm`, `DedustX1000WalletV1`, `DedustUranusFactoryV3`, `DedustUranusMemeV2`, `DedustUranusMemeV3`, `DedustUranusMemeWalletV3` |
| Coffee Swap | DEX factory/init, vaults, pool variants, pool creator, liquidity depository, current and historical LP wallets, staking, CrossDex profiles, and current/legacy MEV Protectors. | `CoffeeFactory`, `CoffeeInit`, `CoffeeVaultNative`, `CoffeeVaultJetton`, `CoffeeVaultExtra`, `CoffeePoolConstantProduct`, `CoffeePoolCurveFiStable`, `CoffeePoolCreator`, `CoffeeLiquidityDepository`, `JettonWalletCoffeeLp`, `CoffeeStakingMaster`, `CoffeeStakingVault`, `CoffeeStakingItem`, `CoffeeCrossDex`, `CoffeeCrossDexLegacy`, `CoffeeCrossDexBidask`, `CoffeeMevProtector`, `CoffeeMevProtectorLegacy` |
| TONCO | Router, pool, account, pool factory, and position NFT. | `Router`, `Pool`, `Account`, `PoolFactory`, `PositionNFT` |
| Bidask | DLMM/DAMM pool factory, pool, range, LP multitoken, internal liquidity vault, DAMM pool, and DAMM LP wallet. | `BidaskPoolFactory`, `BidaskPool`, `BidaskRange`, `BidaskLpMultitoken`, `BidaskInternalLiquidityVault`, `BidaskDammPool`, `BidaskDammLpWallet` |
| GasPump | Six deployed bonding-curve master revisions with versioned storage, message, event, and getter ABIs. | `GasPumpMasterV0`, `GasPumpMasterV1`, `GasPumpMasterV2`, `GasPumpMasterV4`, `GasPumpMasterV5` |
| TonFun | Both deployed TonFun bonding-curve Jetton wallet revisions. | `TonFunBclWalletV1`, `TonFunBclWalletV2` |
| StonksPump | Virtual-liquidity Jetton minters and deployment factories for STON.fi and DeDust launch flows, plus the deployed custom tax Jetton wallet. | `StonksPumpVirtualMinter`, `StonksPumpVirtualFactory`, `StonksPumpCustomJettonWallet` |
| Grambo | Bonding-curve launchpad registry, Jetton master, and activated Jetton wallet contracts. | `GramboFactory`, `GramboJettonMaster`, `GramboJettonWallet` |
| Storm Trade | Perpetual DEX vaults, vAMMs, smart accounts, factory, current and legacy position managers, referral/executor collections and items, prelaunch, LP minter/wallet, and proxy sender. | `StormVault`, `StormVaultNative`, `StormVamm`, `StormVammCoinm`, `SmartAccount`, `SmartAccountBlank`, `SmartAccountFactory`, `StormPositionManager`, `StormPositionManagerLegacy`, `StormReferral`, `StormReferralCollection`, `StormExecutor`, `StormExecutorCollection`, `StormPrelaunch`, `StormLpMinter`, `StormLpWallet`, `StormProxySender` |
| Megaton Finance | Router, exchange/LP Jetton master, wrapped TON minter, and deterministic wrapped TON wallet. | `MegatonRouter`, `MegatonExchange`, `WtonMinter`, `WtonWallet` |
| Moon.cx | Constant-product pool, CLMM range, booster, order factory, and both historical order revisions. | `MoonPool`, `MoonClmmRange`, `MoonBooster`, `MoonOrderFactory`, `MoonOrderOld`, `MoonOrderNew` |
| Signed Cross-DEX | Private signed executor with replay protection and callback-driven multi-protocol routing. | `SignedCrossDexExecutor` |
| ForTON FRT/GRAM Route | Five-contract coordinator, dispatcher, orchestrator, worker, and executor chain for a routed Jetton exchange through a STON.fi pool. | `FrtGramAdapterCoordinator`, `FrtGramAdapterDispatcher`, `FrtGramAdapterOrchestrator`, `FrtGramAdapterWorker`, `FrtGramAdapterExecutor` |

### Staking And Validator Protocols

| Project | Coverage | Contract entries |
| --- | --- | --- |
| Tonstakers | Staking pool, validator controller, tsTON jetton minter/wallet, and payout NFT collection/item. | `TonstakersPool`, `TonstakersValidatorController`, `TsTonMinter`, `TsTonWallet`, `TonstakersPayoutCollection`, `TonstakersPayoutItem` |
| Stakee | Staking pool, validator controller, STAKEED jetton minter/wallet, and payout NFT collection/item. | `StakeePool`, `StakeeValidatorController`, `StakeedMinter`, `StakeedWallet`, `StakeePayoutCollection`, `StakeePayoutItem` |
| Hipo Finance | hGRAM treasury, parent, wallet, bill collection/item, loan, and librarian. | `HipoTreasury`, `HipoParent`, `HipoWallet`, `HipoCollection`, `HipoBill`, `HipoLoan`, `HipoLibrarian` |
| Bemo | Bemo v2 financial jetton master and unstake request contracts. | `BemoFinancial`, `BemoUnstakeRequest` |
| Ton Whales | Nominator pool and proxy contracts, plus the standalone liquid-staking pool ABI. | `WhalesPool`, `WhalesProxy`, `WhalesLiquidStaking` |
| TON Validators Nominator Pool | Validator-managed TON nominator pool. | `NominatorPool` |
| Orbs Single Nominator | Simple/Single Nominator Pool v1.0 and v1.1 contracts for one owner and one validator wallet. | `SingleNominatorV10`, `SingleNominatorV11` |
| JVault | Staking pool, pool factory, and per-user staking wallet contracts. | `JVaultPool`, `JVaultPoolFactory`, `JVaultStakingWallet` |
| tgUSD | tgUSD liquid-staking pool with conversion-ratio getter and complete message surface. | `TgUsdLiquidStaking` |

### Lending, Vaults, And DeFi Applications

| Project | Coverage | Contract entries |
| --- | --- | --- |
| EVAA | Lending protocol master and user contracts, including Pyth and classic master variants. | `EvaaMasterPyth`, `EvaaMasterClassic`, `EvaaUser`, `EvaaBlank` |
| Aqua Protocol | Aqua USD master vault and jetton master interface. | `AquaUsdMasterVault` |
| Pyth Oracle | Pyth price oracle contract for feed updates, governance state, guardian sets, and price getters. | `PythOracle` |
| Affluent | Pools, accounts, batch, multiply vaults, lending vaults, and FactorialTON jetton contracts. | `Pool`, `Account`, `Batch`, `MultiplyVault`, `MultiplyVaultV2`, `LendingVault`, `FactorialTonMinter`, `FactorialTonWallet` |
| Bidask Farming | FF farming vault and per-user NFT staking position contracts. | `FfVault`, `FfVaultPosition` |
| Locker | Locker and locker bill contracts. | `Locker`, `LockerBill` |
| DAOLama | TON liquidity vault and TON-DLP jetton master interface. | `DaolamaVault` |
| tsUSDe | Ethena tsUSDe vault and wallet contracts, including minting, vesting, timelock, and share accounting. | `TsusdeVault`, `TsusdeWallet` |

### Marketplaces, NFT Apps, And Distribution

| Project | Coverage | Contract entries |
| --- | --- | --- |
| Getgems | Deployer, marketplace, sale, auction, on-chain and off-chain offer, raffle, and swap contracts. | `GetgemsDeployer`, `GetgemsNftAuctionV1`, `GetgemsNftAuctionV2`, `GetgemsNftAuctionV3R2`, `GetgemsNftAuctionV3R3`, `GetgemsNftAuctionV4R1`, `GetgemsNftFixpriceSaleV1`, `GetgemsNftSaleLegacy`, `GetgemsNftFixpriceSaleV2`, `GetgemsNftFixpriceSaleV3`, `GetgemsNftFixpriceSaleV3R2`, `GetgemsNftFixpriceSaleV3R3`, `GetgemsNftFixpriceSaleV4R1`, `GetgemsNftMarketplaceV1`, `GetgemsNftMarketplaceV2`, `GetgemsNftOfferV1`, `GetgemsNftOfferV1R3`, `GetgemsOffchainOfferV3`, `GetgemsNftRaffle`, `GetgemsNftSwap` |
| TeleMint | Telegram TeleMint NFT item contract and both deployed Telegram Gift NFT auction revisions. | `TelemintNftItem`, `TelegramGiftNftItem` |
| Fragment | Telegram username and anonymous-number collection/item contracts, plus MarketApp/Fragment buy-routing proxy variants for Telegram collectible purchases. | `FragmentUsernameCollection`, `FragmentNumbersCollection`, `FragmentUsernameItem`, `FragmentNumbersItem`, `FragmentMarketappProxyKnown`, `FragmentMarketappProxySimple`, `FragmentMarketappProxyJetton` |
| Airdrop Interlocker | Airdrop claim interlocker contracts. | `AirdropInterlockerV1`, `AirdropInterlockerV2` |

### Payments, Automation, And Wallet Tooling

| Project | Coverage                                                                                | Contract entries |
| --- |-----------------------------------------------------------------------------------------| --- |
| Invoices | Payload-only invoice body ABI for TON and Jetton payment payloads.                      | `InvoicesPayloadInterface` |
| Payment Channels | Asynchronous two-party payment channel with cooperative and uncooperative settlement.   | `AsyncPaymentChannel` |
| GRAM | Proof-of-work GRAM miner with adaptive complexity and signed administration.            | `GramMiner` |
| Cocoon | Confidential-compute Root, Proxy, Client, Worker, and control Wallet contracts.          | `CocoonRoot`, `CocoonProxy`, `CocoonClient`, `CocoonWorker`, `CocoonWallet` |
| TAC | TAC-compatible Jetton master with EVM token-address discovery.                            | `TacJetton` |
| XTR | Telegram Stars purchase orchestration, versioned user/payment routing, and supply accounting. | `XtrMaster` |
| TonPay | Historical Store v11 and Invoice v9 contracts confirmed from exact official sources and live deployments. | `TonpayStoreV11`, `TonpayInvoiceV9` |
| Tonkeeper Subscriptions | Subscription V1 and V2 wallet/plugin contracts.                                         | `SubscriptionV1`, `SubscriptionV2` |
| TON Cron | Cron interface implementations with `get_cron_info` and `cron_trigger` external bodies. | `Cron` |
| Wallet 2FA Extensions | Tonkeeper and MyTonWallet wallet extension contracts.                            | `Tonkeeper2fa`, `MyTonWallet2fa` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for build, schema, and test workflows.

## License

This project is licensed under the [MIT License](LICENSE).
