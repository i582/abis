import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/gaspump_master_v5.types"
import "../wrappers/GasPumpMasterV5.gen"

const MASTER_ADDRESS = "EQAOvnyeuFkxx0QohTVzRNP3_kU4j7ES-u-K5xQ9FoUneVFC"
const FIXTURE_BOC_PATH = "data/gaspump/master/testdata/GasPumpMasterV5.boc"
const EXPECTED_CODE_HASH = 0xc70f23f2d4fcbadd837e4505bc6eb69f5e30791aa9bbf4b08884e9e6706de14e
const EXPECTED_DATA_HASH = 0xad85d68526534f978e2832c4ce3c77e3a08d6f485085b26e9776a07bd911bb5e

get fun `test gaspump v5 exact code fixture`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(build("GasPumpMasterV5", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test gaspump v5 parses pinned storage and all curated getters`() {
    val contract = GasPumpMasterV5.fromAddress(address(MASTER_ADDRESS));
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
            val storage = GasPumpMasterV5Storage.fromCell(data!);
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
            expect(storage.tradeState).toEqual(0);
            expect(storage.trading.load().version).toEqual(5);
            expect(tradeState).toEqual(0);
            expect(version).toEqual(5);
            expect(jetton.totalSupply).toEqual(supply);
            expect(commissionBalance).toEqual(storage.trading.load().commissionBalance);
            expect(owner).toEqual(fullOwner);
            expect(wallet.castToInternal().getWorkchain()).toEqual(0);
            expect(anotherMinter.castToInternal().getWorkchain()).toEqual(0);
            expect(buyQuote).toBeGreaterOrEqual(0);
            expect(sellQuote).toBeGreaterOrEqual(0);
            expect(abiCid.remainingBitsCount()).toBeGreaterOrEqual(1);
            expect(interfaces.tactContract == 0).toBeFalse();
        }
        TlbAccountStateUninit => Assert.fail("GasPump V5 master is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("GasPump V5 master is frozen at the pinned block"),
    }
}
