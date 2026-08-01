import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/megaton_exchange.types"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXCHANGE_CODE_PATH = "data/megatonfi/exchange/testdata/MegatonExchange.boc"
const EXCHANGE_DATA_PATH = "data/megatonfi/exchange/testdata/MegatonExchange.data.boc"

fun loadBocFixture(name: string, path: string): cell {
    val raw = fs.readBytes(path);
    expect(raw).toBeNotNull();
    val bytes = raw!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build(name, path);
}

get fun `test megaton exchange code fixture has the exact deployed hash`() {
    val code = loadBocFixture("MegatonExchange", EXCHANGE_CODE_PATH);

    expect(code.hash()).toEqual(
        0x0045aba569e0fd4e4124b3d5162764038dc0c0c5e849d32ebee585471d085c7c,
    );
}

get fun `test megaton exchange parses the real mainnet storage fixture`() {
    // Toncenter snapshot of EQCocXc3t9WDrQ2gnq6kD3gJ7ENvA-LJ9PmFhSGX_pG3gHtO
    // at logical time 58924468000001.
    val data = loadBocFixture("MegatonExchangeData", EXCHANGE_DATA_PATH);
    val storage = MegatonExchangeStorage.fromCell(data);
    val pool = storage.poolState.load();
    val masters = pool.tokenMasters.load();
    val wallets = pool.tokenWallets.load();
    val miningSchedule = pool.miningSchedule.load();
    val miningState = pool.miningState.load();
    val dictionaries = storage.dictionaries.load();

    expect(data.hash()).toEqual(
        0x775a6103cfe0838f2fe95a9dc4123f7343dbd269476e05870e126c0770cc76b8,
    );
    expect(storage.totalSupply).toEqual(20357994158989032692);
    expect(storage.swapFee).toEqual(10);
    expect(storage.minimumLpAmount).toEqual(0);
    expect(storage.stopped).toBeFalse();
    expect(storage.liquidityProviderCount).toEqual(3);
    expect(storage.maxLiquidityProviderCount).toEqual(20000);
    expect(storage.adminAddress).toEqual(
        address("0:84E9070FC38C31FDD1B9AB7BA80834959AF44E86C74F921831440024F35CB6AF"),
    );
    expect(storage.routerAddress).toEqual(
        address("0:310B71B340182396F5BA08903081A1EF6AB4DF571A3CA7B05EFFA44C4A3B0F92"),
    );

    expect(pool.tokenABalance).toEqual(24504826007378181909);
    expect(pool.tokenBBalance).toEqual(334551);
    expect(pool.tokenAPendingBalance).toEqual(0);
    expect(pool.tokenBPendingBalance).toEqual(0);
    expect(masters.tokenA).toEqual(
        address("0:64A11836506EBBB63F103E801F1A5B5BF5597C3CB6E87C63BA1463000EE0C101"),
    );
    expect(masters.tokenB).toEqual(
        address("0:BAD48411974FE56BDE6DDBBC612298F166DDF6BE5D504151765204CDBAF0F5F1"),
    );
    expect(wallets.tokenA).toEqual(
        address("0:F0F366ECED34FE9032EE2E4A36BA29D355E7529B79752B482A2D5E29ECA6EC6E"),
    );
    expect(wallets.tokenB).toEqual(
        address("0:1EF61905A55E52D4B66982E6DB1BA63325201655146BB40D1DE4B7C70846412D"),
    );

    expect(miningSchedule.miningAmount).toEqual(18918750009686400);
    expect(miningSchedule.datetimeAmount).toEqual(217013889);
    expect(miningSchedule.minableTime).toEqual(1677110400);
    expect(miningSchedule.halfLife).toEqual(124416000);
    expect(miningState.lastIndex).toEqual(10371886);
    expect(miningState.lastMined).toEqual(12168750006230400);
    expect(dictionaries.liquidityProviders.isEmpty()).toBeFalse();
    expect(dictionaries.operationFees.isEmpty()).toBeFalse();
}
