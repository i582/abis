import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_vamm_coinm.types"

const FIXTURE_BOC_PATH = "data/storm/vamm_coinm/testdata/StormVammCoinm.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xbdaa69d9ab41b0c3635359a6b3d7cdd0fd2dbeb2b23c745e304e64e06a21f3ff
const EXPECTED_ASSET_ID = 10
const EXPECTED_SETTLEMENT_ASSET_ID = 10
const EXPECTED_VAMM_TYPE = 1
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORM_VAMM_COINM_ADDRESS = "EQAkHkgOmtsM30Di4-w7sM9ST7UgzKArLikuc0gXvCkf-39Z"
const MAINNET_STORM_NATIVE_VAULT_ADDRESS = "EQDpJnZP89Jyxz3euDaXXFUhwCWtaOeRmiUJTi3jGYgF8fnj"

struct LoadedStormVammCoinmStorage {
    data: cell
    storage: StormVammCoinmStorage
}

struct StormVammCoinmFork {
    address: address
}

fun mainnetStormVammCoinm(): StormVammCoinmFork {
    return StormVammCoinmFork { address: address(MAINNET_STORM_VAMM_COINM_ADDRESS) };
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectMaybeRefPresenceMatchesMap(
    mutate raw: RemainingBitsAndRefs,
    expected: map<uint256, cell>,
): void {
    if (raw.loadBool()) {
        expect(expected.isEmpty()).toBeFalse();
        raw.loadRef();
    } else {
        expect(expected.isEmpty()).toBeTrue();
    }
}

fun stormVammCoinmGetAmmContractData(vamm: StormVammCoinmFork): cell {
    return net.runGetMethod(vamm.address, "get_amm_contract_data");
}

fun stormVammCoinmGetAmmName(vamm: StormVammCoinmFork): GetAmmNameReply {
    return net.runGetMethod(vamm.address, "get_amm_name");
}

fun stormVammCoinmGetAmmStatus(vamm: StormVammCoinmFork): GetAmmStatusReply {
    return net.runGetMethod(vamm.address, "get_amm_status");
}

fun stormVammCoinmGetAmmState(vamm: StormVammCoinmFork): GetAmmStateReply {
    return net.runGetMethod(vamm.address, "get_amm_state");
}

fun stormVammCoinmGetExchangeSettings(vamm: StormVammCoinmFork): GetExchangeSettingsReply {
    return net.runGetMethod(vamm.address, "get_exchange_settings");
}

fun stormVammCoinmGetOracleData(vamm: StormVammCoinmFork): GetOracleDataReply {
    return net.runGetMethod(vamm.address, "get_oracle_data");
}

fun stormVammCoinmGetFundingSettings(vamm: StormVammCoinmFork): GetFundingSettingsReply {
    return net.runGetMethod(vamm.address, "get_funding_settings");
}

fun stormVammCoinmGetDayTradingData(vamm: StormVammCoinmFork): GetDayTradingDataReply {
    return net.runGetMethod(vamm.address, "get_day_trading_data");
}

fun stormVammCoinmGetVammType(vamm: StormVammCoinmFork): uint32 {
    return net.runGetMethod(vamm.address, "get_vamm_type");
}

fun stormVammCoinmGetSettlementOracleData(vamm: StormVammCoinmFork): GetSettlementOracleDataReply {
    return net.runGetMethod(vamm.address, "get_settlement_oracle_data");
}

fun loadStormVammCoinmStorageFromFork(vamm: StormVammCoinmFork): LoadedStormVammCoinmStorage {
    val account = testing.getAccountState(vamm.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StormVammCoinm", FIXTURE_BOC_PATH).hash());
            return LoadedStormVammCoinmStorage {
                data: data!,
                storage: StormVammCoinmStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm VAMM CoinM mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm VAMM CoinM mainnet fixture account is frozen");
        }
    }
}

fun expectStormVammCoinmGettersMatchStorage(
    vamm: StormVammCoinmFork,
    loaded: LoadedStormVammCoinmStorage,
): void {
    val storage = loaded.storage;
    val ammName = stormVammCoinmGetAmmName(vamm);
    val status = stormVammCoinmGetAmmStatus(vamm);
    val ammState = stormVammCoinmGetAmmState(vamm);
    val storageAmmState = storage.ammState.load();
    val storageExchangeSettingsTyped = storage.exchangeSettings.load();
    var storageExchangeSettings = storage.exchangeSettings.beginParse();
    val oracleData = stormVammCoinmGetOracleData(vamm);
    val fundingSettings = stormVammCoinmGetFundingSettings(vamm);
    val dayTradingData = stormVammCoinmGetDayTradingData(vamm);
    val exchangeSettings = stormVammCoinmGetExchangeSettings(vamm);
    val settlementData = stormVammCoinmGetSettlementOracleData(vamm);
    val storageSettlementData = storage.settlementOracleData.load();

    expect(scripts.isContractDeployed(vamm.address)).toBeTrue();
    expect(stormVammCoinmGetVammType(vamm)).toEqual(EXPECTED_VAMM_TYPE);
    expect(stormVammCoinmGetAmmContractData(vamm).hash()).toEqual(loaded.data.hash());

    expect(storage.vaultAddress).toEqual(address(MAINNET_STORM_NATIVE_VAULT_ADDRESS));
    expect(storage.assetId).toEqual(EXPECTED_ASSET_ID);
    expect(ammName.vaultAddr).toEqual(storage.vaultAddress);
    expect(ammName.assetId).toEqual(storage.assetId);

    expect(status.closeOnly).toEqual(storage.closeOnly);
    expect(status.paused).toEqual(storage.paused);
    expect(status.pauseAt).toEqual(storage.pauseAt);
    expect(status.unpauseAt).toEqual(storage.unpauseAt);

    expect(ammState.quoteAssetReserve).toEqual(storageAmmState.quoteAssetReserve);
    expect(ammState.baseAssetReserve).toEqual(storageAmmState.baseAssetReserve);
    expect(ammState.quoteAssetWeight).toEqual(storageAmmState.quoteAssetWeight);
    expect(ammState.totalLongPositionSize).toEqual(storageAmmState.totalLongPositionSize);
    expect(ammState.totalShortPositionSize).toEqual(storageAmmState.totalShortPositionSize);
    expect(ammState.openInterestLong).toEqual(storageAmmState.openInterestLong);
    expect(ammState.openInterestShort).toEqual(storageAmmState.openInterestShort);
    expect(ammState.latestLongCumulativePremiumFraction).toEqual(
        storageAmmState.latestLongCumulativePremiumFraction,
    );
    expect(ammState.latestShortCumulativePremiumFraction).toEqual(
        storageAmmState.latestShortCumulativePremiumFraction,
    );
    expect(ammState.nextFundingBlockTimestamp).toEqual(storageAmmState.nextFundingBlockTimestamp);

    expect(storageExchangeSettingsTyped.toCell().hash()).toEqual(storage.exchangeSettings.hash());
    expect(exchangeSettings.fee).toEqual(storageExchangeSettingsTyped.fee);
    expect(exchangeSettings.maxOpenNotional).toEqual(storageExchangeSettingsTyped.maxOpenNotional);
    expect(exchangeSettings.minInitMarginRatio).toEqual(
        storageExchangeSettingsTyped.minInitMarginRatio,
    );
    expect(exchangeSettings.directIncreaseEnabled).toEqual(
        storageExchangeSettingsTyped.directIncreaseEnabled,
    );
    expect(exchangeSettings.directCloseEnabled).toEqual(
        storageExchangeSettingsTyped.directCloseEnabled,
    );
    expect(exchangeSettings.executorsWhitelist).toEqual(
        storageExchangeSettingsTyped.executorsWhitelist,
    );
    expect(exchangeSettings.executorFee).toEqual(storageExchangeSettingsTyped.executorFee);
    expect(exchangeSettings.v3CloseDelay).toEqual(storageExchangeSettingsTyped.v3CloseDelay);

    expect(exchangeSettings.fee).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.rolloverFee).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.fundingPeriod).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.initMarginRatio).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.maintenanceMarginRatio).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.liquidationFeeRatio).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.partialLiquidationRatio).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.spreadLimit).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.maxPriceImpact).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.maxPriceSpread).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.maxOpenNotional).toEqual(storageExchangeSettings.loadCoins());
    expect(exchangeSettings.feeToStakersPercent).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.fundingMode).toEqual(storageExchangeSettings.loadUint(2));
    expect(exchangeSettings.minPartialLiquidationNotional).toEqual(
        storageExchangeSettings.loadCoins(),
    );
    expect(exchangeSettings.minInitMarginRatio).toEqual(storageExchangeSettings.loadUint(32));
    expect(exchangeSettings.directIncreaseEnabled).toEqual(storageExchangeSettings.loadBool());
    expect(exchangeSettings.directCloseEnabled).toEqual(storageExchangeSettings.loadBool());
    expectMaybeRefPresenceMatchesMap(
        mutate storageExchangeSettings,
        exchangeSettings.executorsWhitelist,
    );
    val lowFundingFnA = storageExchangeSettings.loadUint(64);
    val lowFundingFnB = storageExchangeSettings.loadUint(64);
    val highFundingFnA = storageExchangeSettings.loadInt(64);
    val highFundingFnB = storageExchangeSettings.loadUint(64);
    val inflectionPoint = storageExchangeSettings.loadUint(64);
    val executorFee = storageExchangeSettings.loadUint(32);
    val v3CloseDelay = storageExchangeSettings.loadUint(32);
    expect(exchangeSettings.lowFundingFnA).toEqual(lowFundingFnA);
    expect(exchangeSettings.lowFundingFnB).toEqual(lowFundingFnB);
    expect(exchangeSettings.highFundingFnA).toEqual(highFundingFnA);
    expect(exchangeSettings.highFundingFnB).toEqual(highFundingFnB);
    expect(exchangeSettings.inflectionPoint).toEqual(inflectionPoint);
    expect(exchangeSettings.executorFee).toEqual(executorFee);
    expect(exchangeSettings.v3CloseDelay).toEqual(v3CloseDelay);

    expect(oracleData.oracleLastPrice).toEqual(storage.oracleLastPrice);
    expect(oracleData.oracleLastSpread).toEqual(storage.oracleLastSpread);
    expect(oracleData.oracleLastTimestamp).toEqual(storage.oracleLastTimestamp);
    expect(oracleData.oracleMaxDeviation).toEqual(storage.oracleMaxDeviation);
    expect(oracleData.oracleValidityPeriod).toEqual(storage.oracleValidityPeriod);
    expect(oracleData.oraclePublicKeysCount).toEqual(storage.oraclePublicKeysCount);
    expect(oracleData.oraclePublicKeysRef.hash()).toEqual(storage.oraclePublicKeysRef.hash());

    expect(settlementData.settlementLastPrice).toEqual(storageSettlementData.settlementLastPrice);
    expect(settlementData.settlementLastSpread).toEqual(storageSettlementData.settlementLastSpread);
    expect(settlementData.settlementLastTimestamp).toEqual(
        storageSettlementData.settlementLastTimestamp,
    );
    expect(settlementData.settlementMaxDeviation).toEqual(
        storageSettlementData.settlementMaxDeviation,
    );
    expect(settlementData.settlementValidityPeriod).toEqual(
        storageSettlementData.settlementValidityPeriod,
    );
    expect(settlementData.settlementAssetId).toEqual(storageSettlementData.settlementAssetId);
    expect(settlementData.settlementAssetId).toEqual(EXPECTED_SETTLEMENT_ASSET_ID);

    expect(fundingSettings.lowFundingFnA).toEqual(lowFundingFnA);
    expect(fundingSettings.lowFundingFnB).toEqual(lowFundingFnB);
    expect(fundingSettings.highFundingFnA).toEqual(highFundingFnA);
    expect(fundingSettings.highFundingFnB).toEqual(highFundingFnB);
    expect(fundingSettings.inflectionPoint).toEqual(inflectionPoint);

    expect(dayTradingData.maxLeverage).toEqual(storage.dayTradingMaxLeverage);
    expect(dayTradingData.active).toEqual(storage.dayTradingMaxLeverage > 0);

    expect(storageAmmState.quoteAssetReserve).toBeGreater(0);
    expect(exchangeSettings.fee).toBeGreater(0);
}

get fun `test storm vamm coinm code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StormVammCoinm", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storm vamm coinm mainnet storage and getters`() {
    val vamm = mainnetStormVammCoinm();
    val loaded = loadStormVammCoinmStorageFromFork(vamm);

    expectStormVammCoinmGettersMatchStorage(vamm, loaded);

    println("STORM_VAMM_COINM_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_VAMM_COINM_ADDRESS={}", vamm.address);
    println("STORM_VAMM_COINM_STORAGE={}", loaded.storage);
}
