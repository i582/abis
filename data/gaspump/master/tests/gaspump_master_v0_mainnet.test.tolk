import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/gaspump_master_v0.types"
import "../wrappers/GasPumpMasterV0.gen"

const MASTER_ADDRESS = "EQAlIOIqpzzuAdHxYGVz5TCxOybNwRTvWv2zdmhK0OBp0t-z"
const FIXTURE_BOC_PATH = "data/gaspump/master/testdata/GasPumpMasterV0.boc"
const EXPECTED_CODE_HASH = 0xea8c761468304a776a1f4971062b2ce81301336ade35334d28fbb9ca33554d17
const EXPECTED_DATA_HASH = 0xae3d1ba9455cef96beb5d0963f44e7d4188792e7b8b1afe86c8ba2cb00ff6600
const EXPECTED_VERSION = 0
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const PINNED_MAINNET_BLOCK = 71819864

fun master(): GasPumpMasterV0 {
    return GasPumpMasterV0.fromAddress(address(MASTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test gaspump v0 exact code fixture`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("GasPumpMasterV0", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test gaspump v0 parses pinned storage and available getters`() {
    val contract = master();
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            val storage = GasPumpMasterV0Storage.fromCell(data!);
            val (
                fullTotalSupply,
                fullMintable,
                fullOwner,
                fullContent,
                fullWalletCode,
                fullTradeState,
                fullBondingCurveBalance,
                fullCommissionBalance,
                fullVersion,
                fullCurveParameters,
                fullCommissionPromille,
                fullTonBalance,
                fullPriceNanotons,
                fullSupplyLeft,
                fullMaxSupply,
            ) = contract.getFullJettonData();
            val jetton = contract.getJettonData();
            val owner = contract.owner();
            val wallet = contract.getWalletAddress(contract.address as any_address);
            val anotherMinter = contract.anotherMinterAddress();
            val buyQuote = contract.getBuyAmount(1000000000);
            val abiCid = contract.getAbiIpfs();
            val interfaces = contract.supportedInterfaces();

            expect(storage.initialized).toBeTrue();
            expect(storage.trading.load().version).toEqual(EXPECTED_VERSION);
            expect(fullVersion).toEqual(EXPECTED_VERSION);
            expect(fullTotalSupply).toEqual(storage.totalSupply);
            expect(fullCommissionBalance).toEqual(storage.commissionBalance);
            expect(jetton.totalSupply).toEqual(fullTotalSupply);
            expect(owner).toEqual(fullOwner);
            expect(wallet.castToInternal().getWorkchain()).toEqual(0);
            expect(anotherMinter.castToInternal().getWorkchain()).toEqual(0);
            expect(buyQuote).toBeGreaterOrEqual(0);
            expect(abiCid.remainingBitsCount()).toBeGreaterOrEqual(1);
            expect(interfaces.tactContract == 0).toBeFalse();
            println("GASPUMP_V0_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
        }
        TlbAccountStateUninit => Assert.fail("GasPump V0 master is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("GasPump V0 master is frozen at the pinned block"),
    }
}
