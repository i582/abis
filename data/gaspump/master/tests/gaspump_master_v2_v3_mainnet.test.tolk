import "@acton/build"
import "@acton/fs"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/gaspump_master_v2_v3.types"
import "../wrappers/GasPumpMasterV2.gen"

const V2_ADDRESS = "EQAlrMn0CB2gCbSYaZTo7t_l3d063RETWvcp8v0IG0ya3GYH"
const V3_ADDRESS = "EQDgIa5eizZd87mm063uOr1ZO1EvEDE8m-e7dG-pcH8hsimp"
const V2_FIXTURE = "data/gaspump/master/testdata/GasPumpMasterV2.boc"
const V3_FIXTURE = "data/gaspump/master/testdata/GasPumpMasterV3.boc"
const V2_HASH = 0x7a95403c57c7852080f1f1566e3e6b5a731437051a87e8464e5d32977f956958
const V3_HASH = 0xb3cc4415154a9f3b347b4fa71dd0e8d4df623a66861cc9d07b103c95fd5e9645
const V2_DATA_HASH = 0xdf806f09a7e153caded121f61f1aaa4d8aba89f2db7161de4ec44e09bb02ee96
const V3_DATA_HASH = 0x772e96171d897591df223372501e5e3a9a96835ec6d5cfeaba85369b6677756f

fun validateMaster(
    contractAddress: address,
    expectedHash: int,
    expectedDataHash: int,
    expectedVersion: int,
): void {
    val contract = GasPumpMasterV2.fromAddress(contractAddress);
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();
    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(expectedHash);
            expect(data!.hash()).toEqual(expectedDataHash);
            val storage = GasPumpMasterV2V3Storage.fromCell(data!);
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
            expect(storage.trading.load().version).toEqual(expectedVersion);
            expect(tradeState).toEqual(0);
            expect(version).toEqual(expectedVersion);
            expect(jetton.totalSupply).toEqual(supply);
            expect(commissionBalance).toEqual(storage.commissionBalance);
            expect(owner).toEqual(fullOwner);
            expect(wallet.castToInternal().getWorkchain()).toEqual(0);
            expect(anotherMinter.castToInternal().getWorkchain()).toEqual(0);
            expect(buyQuote).toBeGreaterOrEqual(0);
            if (expectedVersion == 3) {
                val sellQuote = contract.getSellAmount(1000000000);
                expect(sellQuote).toBeGreaterOrEqual(0);
            }
            expect(abiCid.remainingBitsCount()).toBeGreaterOrEqual(1);
            expect(interfaces.tactContract == 0).toBeFalse();
        }
        TlbAccountStateUninit => Assert.fail("GasPump V2/V3 master is uninitialized at the pinned block"),
        TlbAccountStateFrozen => Assert.fail("GasPump V2/V3 master is frozen at the pinned block"),
    }
}

get fun `test gaspump v2 and v3 exact code fixtures`() {
    val v2 = fs.readBytes(V2_FIXTURE);
    val v3 = fs.readBytes(V3_FIXTURE);
    expect(v2).toBeNotNull();
    expect(v3).toBeNotNull();
    expect(build("GasPumpMasterV2", V2_FIXTURE).hash()).toEqual(V2_HASH);
    expect(build("GasPumpMasterV2", V3_FIXTURE).hash()).toEqual(V3_HASH);
}

get fun `test gaspump v2 parses pinned storage and available getters`() {
    validateMaster(address(V2_ADDRESS), V2_HASH, V2_DATA_HASH, 2);
}

get fun `test gaspump v3 parses pinned storage and all curated getters`() {
    validateMaster(address(V3_ADDRESS), V3_HASH, V3_DATA_HASH, 3);
}
