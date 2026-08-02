import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/gaspump_master_v4.types"
import "../wrappers/GasPumpMasterV4.gen"

const MASTER_ADDRESS = "EQAG9pTWO5z_Al9wG61a5_pCv90UfO1mFxDWPzTCyBF9VXcI"
const FIXTURE_BOC_PATH = "data/gaspump/master/testdata/GasPumpMasterV4.boc"
const EXPECTED_CODE_HASH = 0xaf978967b56eac90117d045eb23d330abea41ba407eed6ae02cd05d921ae1ba5
const EXPECTED_DATA_HASH = 0xf25a83b568c911cd2fe8bfc1089844e22cf874967bcb5e75551db522f55e6c65

get fun `test gaspump v4 exact code fixture`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(build("GasPumpMasterV4", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test gaspump v4 parses pinned storage and available getters`() {
    val contract = GasPumpMasterV4.fromAddress(address(MASTER_ADDRESS));
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
            val storage = GasPumpMasterV4Storage.fromCell(data!);
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
            val abiCid = contract.getAbiIpfs();
            val interfaces = contract.supportedInterfaces();

            expect(storage.initialized).toBeTrue();
            expect(storage.tradeState).toEqual(0);
            expect(storage.trading.load().version).toEqual(4);
            expect(tradeState).toEqual(0);
            expect(version).toEqual(4);
            expect(jetton.totalSupply).toEqual(supply);
            expect(commissionBalance).toEqual(storage.trading.load().commissionBalance);
            expect(owner).toEqual(fullOwner);
            expect(wallet.castToInternal().getWorkchain()).toEqual(0);
            expect(anotherMinter.castToInternal().getWorkchain()).toEqual(0);
            expect(buyQuote).toBeGreaterOrEqual(0);
            expect(abiCid.remainingBitsCount()).toBeGreaterOrEqual(1);
            expect(interfaces.tactContract == 0).toBeFalse();
        }
        TlbAccountStateUninit => Assert.fail("GasPump V4 master is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("GasPump V4 master is frozen at the pinned block"),
    }
}
