import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/gaspump_master_v1.types"
import "../wrappers/GasPumpMasterV1.gen"

const MASTER_ADDRESS = "EQCxOvhNxktsigfh760fgWR8eYhAhEhLVYbbATeRz8B6s9Df"
const FIXTURE_BOC_PATH = "data/gaspump/master/testdata/GasPumpMasterV1.boc"
const EXPECTED_CODE_HASH = 0xcc7245578a202c2fb6fee3758c241906cf48037c44694105e64a917568c33a5c
const EXPECTED_DATA_HASH = 0x6a88baee435b8248416487c1bb652ab19b7c57ce16a94a41627b2eaa8b3766a1
const EXPECTED_VERSION = 1
const EXPECTED_TRADE_STATE = 2
const EXPECTED_BOC_MAGIC = 0xb5ee9c72

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test gaspump v1 exact code fixture`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("GasPumpMasterV1", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test gaspump v1 parses pinned storage and available getters`() {
    val contract = GasPumpMasterV1.fromAddress(address(MASTER_ADDRESS));
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
            val storage = GasPumpMasterV1Storage.fromCell(data!);
            val (
                supply,
                mintable,
                fullOwner,
                content,
                walletCode,
                tradeState,
                curveBalance,
                commissionBalance,
                version,
                curveParams,
                commissionPromille,
                tonBalance,
                price,
                supplyLeft,
                maxSupply,
            ) = contract.getFullJettonData();
            val jetton = contract.getJettonData();
            val owner = contract.owner();
            val wallet = contract.getWalletAddress(contract.address as any_address);
            val anotherMinter = contract.anotherMinterAddress();
            val buyQuote = contract.getBuyAmount(1000000000);
            val sellQuote = contract.getSellAmount(1000000000);
            val abiCid = contract.getAbiIpfs();
            val interfaces = contract.supportedInterfaces();

            expect(storage.initialized).toBeTrue();
            expect(storage.tradeState).toEqual(EXPECTED_TRADE_STATE);
            expect(storage.trading.load().version).toEqual(EXPECTED_VERSION);
            expect(tradeState).toEqual(EXPECTED_TRADE_STATE);
            expect(version).toEqual(EXPECTED_VERSION);
            expect(jetton.totalSupply).toEqual(supply);
            expect(commissionBalance).toEqual(storage.commissionBalance);
            expect(owner).toEqual(fullOwner);
            expect(wallet.castToInternal().getWorkchain()).toEqual(0);
            expect(anotherMinter.castToInternal().getWorkchain()).toEqual(0);
            expect(buyQuote).toBeGreaterOrEqual(0);
            expect(sellQuote).toBeGreaterOrEqual(0);
            expect(abiCid.remainingBitsCount()).toBeGreaterOrEqual(1);
            expect(interfaces.tactContract == 0).toBeFalse();
        }
        TlbAccountStateUninit => Assert.fail("GasPump V1 master is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("GasPump V1 master is frozen at the pinned block"),
    }
}
