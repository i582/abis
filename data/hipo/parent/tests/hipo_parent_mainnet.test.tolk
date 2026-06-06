import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/hipo_parent.types"
import "../wrappers/HipoParent.gen"

const FIXTURE_BOC_PATH = "data/hipo/parent/testdata/HipoParent.boc"
const FIXTURE_DATA_BOC_PATH = "data/hipo/parent/testdata/HipoParent.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x44377ca68af877b8f26f47f153d6a2d2de134f120348d10d016cf51c00aaf019
const EXPECTED_DATA_HASH = 0x120dc0613067612a6a453a39061aaf85bfec39c4d8e62de5f19243f52d70c5e1
const EXPECTED_TOTAL_TOKENS = 715228431499693
const EXPECTED_WALLET_CODE_HASH = 0x50b917d9fd5b95760993287677d04812a15aa55e6b71d0f9226ecd7c20c3d82a
const EXPECTED_CONTENT_HASH = 0x5b867a6893b0ff5eceb21286e1492b541dd586b19e8b61a4c502d023020cd7fc
const PINNED_MAINNET_BLOCK = 71589284

const MAINNET_HIPO_PARENT_ADDRESS = "EQDPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO_h76w"
const MAINNET_HIPO_TREASURY_ADDRESS = "EQCLyZHP4Xe8fpchQz76O-_RmUhaVc_9BAoGyJrwJrcbz2eZ"
const MAINNET_HIPO_REPRESENTATIVE_WALLET_OWNER = "EQB_K-smTrvWqB-LuWc3OU84Cjt18MIOtVDcTBMS3WDgzN3Z"
const MAINNET_HIPO_REPRESENTATIVE_WALLET_ADDRESS = "EQBwh1XGDsEongigw0iz-s-3pkkeMrpIKioELjbmGB9BDMbo"

struct LoadedHipoParentStorage {
    data: cell
    storage: HipoParentStorage
}

fun mainnetHipoParent(): HipoParent {
    return HipoParent.fromAddress(address(MAINNET_HIPO_PARENT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadHipoParentStorageFromFork(parent: HipoParent): LoadedHipoParentStorage {
    val account = testing.getAccountState(parent.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("HipoParent", FIXTURE_BOC_PATH).hash());
            return LoadedHipoParentStorage {
                data: data!,
                storage: HipoParentStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("Hipo Parent mainnet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Hipo Parent mainnet account is frozen");
        }
    }
}

fun expectHipoParentGettersMatchStorage(parent: HipoParent, loaded: LoadedHipoParentStorage): void {
    val storage = loaded.storage;
    val jettonData = parent.getJettonData();
    val representativeWallet = parent.getWalletAddress(address(MAINNET_HIPO_REPRESENTATIVE_WALLET_OWNER));

    expect(scripts.isContractDeployed(parent.address)).toBeTrue();
    expect(storage.totalTokens).toBeGreater(0);
    expect(storage.treasury).toEqual(address(MAINNET_HIPO_TREASURY_ADDRESS));
    expect(storage.walletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(storage.content.hash()).toEqual(EXPECTED_CONTENT_HASH);

    expect(jettonData.totalTokens).toEqual(storage.totalTokens);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.treasury).toEqual(storage.treasury);
    expect(jettonData.content.hash()).toEqual(storage.content.hash());
    expect(jettonData.walletCode.hash()).toEqual(storage.walletCode.hash());
    expect(representativeWallet).toEqual(address(MAINNET_HIPO_REPRESENTATIVE_WALLET_ADDRESS));

    println("HIPO_PARENT_STORAGE={}", storage);
}

get fun `test hipo parent code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(FIXTURE_DATA_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val code = build("HipoParent", FIXTURE_BOC_PATH);
    val data = build("HipoParentData", FIXTURE_DATA_BOC_PATH);
    val storage = HipoParentStorage.fromCell(data);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.totalTokens).toEqual(EXPECTED_TOTAL_TOKENS);
    expect(storage.treasury).toEqual(address(MAINNET_HIPO_TREASURY_ADDRESS));
    expect(storage.walletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(storage.content.hash()).toEqual(EXPECTED_CONTENT_HASH);
}

get fun `test hipo parent parses live fork storage and getters`() {
    val parent = mainnetHipoParent();
    val loaded = loadHipoParentStorageFromFork(parent);
    expectHipoParentGettersMatchStorage(parent, loaded);
}
