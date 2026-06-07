import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/storm_vamm.types"

const FIXTURE_BOC_PATH = "data/storm/vamm/testdata/StormVamm.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xea4749d902f12bed57b61b8c5531167d10aa015b628b0592852fd2b69ef7ba27
const EXPECTED_ASSET_ID = 10
const EXPECTED_VAMM_TYPE = 0
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_STORM_VAMM_ADDRESS = "EQA8kxbUovK2p21p55S9iZA0mbX3mPZus6_rAkHioW9iNjeZ"
const MAINNET_STORM_VAULT_ADDRESS = "EQAz6ehNfL7_8NI7OVh1Qg46HsuC4kFpK-icfqK9J3Frd6CJ"

struct LoadedStormVammStorage {
    data: cell
    storage: StormVammStorage
}

struct StormVammFork {
    address: address
}

fun mainnetStormVamm(): StormVammFork {
    return StormVammFork { address: address(MAINNET_STORM_VAMM_ADDRESS) };
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun expectCellHashEqualsMaybe(actual: cell, expected: cell?): void {
    if (expected == null) {
        expect(actual.hash()).toEqual(createEmptyCell().hash());
    } else {
        expect(actual.hash()).toEqual(expected!.hash());
    }
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

fun stormVammGetAmmContractData(vamm: StormVammFork): cell {
    return net.runGetMethod(vamm.address, "get_amm_contract_data");
}

fun stormVammGetAmmName(vamm: StormVammFork): GetAmmNameReply {
    return net.runGetMethod(vamm.address, "get_amm_name");
}

fun stormVammGetAmmStatus(vamm: StormVammFork): GetAmmStatusReply {
    return net.runGetMethod(vamm.address, "get_amm_status");
}

fun stormVammGetAmmState(vamm: StormVammFork): GetAmmStateReply {
    return net.runGetMethod(vamm.address, "get_amm_state");
}

fun stormVammGetExchangeSettings(vamm: StormVammFork): GetExchangeSettingsReply {
    return net.runGetMethod(vamm.address, "get_exchange_settings");
}

fun stormVammGetOracleData(vamm: StormVammFork): GetOracleDataReply {
    return net.runGetMethod(vamm.address, "get_oracle_data");
}

fun stormVammGetFundingSettings(vamm: StormVammFork): GetFundingSettingsReply {
    return net.runGetMethod(vamm.address, "get_funding_settings");
}

fun stormVammGetDayTradingData(vamm: StormVammFork): GetDayTradingDataReply {
    return net.runGetMethod(vamm.address, "get_day_trading_data");
}

fun stormVammGetVammType(vamm: StormVammFork): uint32 {
    return net.runGetMethod(vamm.address, "get_vamm_type");
}

fun loadStormVammStorageFromFork(vamm: StormVammFork): LoadedStormVammStorage {
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
            expect(code!.hash()).toEqual(build("StormVamm", FIXTURE_BOC_PATH).hash());
            return LoadedStormVammStorage {
                data: data!,
                storage: StormVammStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Storm VAMM mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Storm VAMM mainnet fixture account is frozen");
        }
    }
}

fun expectStormVammGettersMatchStorage(vamm: StormVammFork, loaded: LoadedStormVammStorage): void {
    val storage = loaded.storage;
    val ammName = stormVammGetAmmName(vamm);
    val status = stormVammGetAmmStatus(vamm);
    val ammState = stormVammGetAmmState(vamm);
    val storageAmmState = storage.ammState.load();
    val exchangeSettings = stormVammGetExchangeSettings(vamm);
    val storageExchangeSettingsTyped = storage.exchangeSettings.load();
    var storageExchangeSettings = storage.exchangeSettings.beginParse();
    val oracleData = stormVammGetOracleData(vamm);
    val fundingSettings = stormVammGetFundingSettings(vamm);
    val dayTradingData = stormVammGetDayTradingData(vamm);

    expect(scripts.isContractDeployed(vamm.address)).toBeTrue();
    expect(stormVammGetVammType(vamm)).toEqual(EXPECTED_VAMM_TYPE);
    expect(stormVammGetAmmContractData(vamm).hash()).toEqual(loaded.data.hash());

    expect(storage.reservedCoins).toEqual(0);
    expect(storage.vaultAddress).toEqual(address(MAINNET_STORM_VAULT_ADDRESS));
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

get fun `test storm vamm code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StormVamm", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test storm vamm mainnet storage and getters`() {
    val vamm = mainnetStormVamm();
    val loaded = loadStormVammStorageFromFork(vamm);

    expectStormVammGettersMatchStorage(vamm, loaded);

    println("STORM_VAMM_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_VAMM_ADDRESS={}", vamm.address);
    println("STORM_VAMM_STORAGE={}", loaded.storage);
}
