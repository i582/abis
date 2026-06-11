import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_lp_account_v1.types"
import "../wrappers/StonfiLpAccountV1.gen"

const FIXTURE_BOC_PATH = "data/stonfi/v1/lp_account/testdata/StonfiLpAccountV1.boc"
const LIVE_DATA_BOC = "te6ccgEBAQEARgAAh4AVNOalswyRkG4pCMopecKdFTbQWmMc0eZ0+lHY/BngFzAA1Fs0xcrYox3oxAoV/Y+h0s6lM84rNXg77EJ3kUcwhEQC"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xfe9085c0bcc4f58983c38c62a46d46646ccf5dd1ae042dfa0f8355d0e9812175
const EXPECTED_DATA_HASH = 0x9efe5ca6fc897805ac99b51c8dd5b59ef79fccffcb4b6cd3d19fcf881f667feb
const PINNED_MAINNET_BLOCK = 71819864

const MAINNET_LP_ACCOUNT_ADDRESS = "EQBflFgUQWx0fSFdbmUdIr_VtQU99Zn1z1ey6iKB_Av1yF3v"
const EXPECTED_USER_ADDRESS = "EQCppzUtmGSMg3FIRlFLzhToqbaC0xjmjzOn0o7H4M8Aua1t"
const EXPECTED_POOL_ADDRESS = "EQA1Fs0xcrYox3oxAoV_Y-h0s6lM84rNXg77EJ3kUcwhEfwn"

fun mainnetStonfiLpAccountV1(): StonfiLpAccountV1 {
    return StonfiLpAccountV1.fromAddress(address(MAINNET_LP_ACCOUNT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun liveDataCell(): cell {
    return parseCellFromBase64(LIVE_DATA_BOC);
}

fun expectedLiveStorage(): StonfiLpAccountV1Storage {
    return {
        userAddress: address(EXPECTED_USER_ADDRESS),
        poolAddress: address(EXPECTED_POOL_ADDRESS),
        amount0: 0,
        amount1: 0,
    };
}

fun expectLiveStorage(storage: StonfiLpAccountV1Storage): void {
    expect(storage.userAddress).toEqual(address(EXPECTED_USER_ADDRESS));
    expect(storage.poolAddress).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(storage.amount0).toEqual(0);
    expect(storage.amount1).toEqual(0);
}

fun loadStonfiLpAccountV1StorageFromFork(lpAccount: StonfiLpAccountV1): StonfiLpAccountV1Storage {
    val account = testing.getAccountState(lpAccount.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiLpAccountV1", FIXTURE_BOC_PATH).hash());
            return StonfiLpAccountV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi LP Account v1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi LP Account v1 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi lp account v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("StonfiLpAccountV1", FIXTURE_BOC_PATH);
    val codeFromManifest = build("StonfiLpAccountV1");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test stonfi lp account v1 saved mainnet data parses storage`() {
    val data = liveDataCell();
    val storage = StonfiLpAccountV1Storage.fromCell(data);
    val expectedStorage = expectedLiveStorage();
    val derivedContract = StonfiLpAccountV1.fromStorage(expectedStorage);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(derivedContract.address).toEqual(address(MAINNET_LP_ACCOUNT_ADDRESS));
    expect(derivedContract.stateInit).toBeNotNull();
    expect(derivedContract.stateInit!.data.hash()).toEqual(data.hash());
    expectLiveStorage(storage);

    println("STONFI_LP_ACCOUNT_V1_SAVED_MAINNET_STORAGE={}", storage);
}

get fun `test stonfi lp account v1 mainnet getter matches fork storage`() {
    val lpAccount = mainnetStonfiLpAccountV1();
    expect(scripts.isContractDeployed(lpAccount.address)).toBeTrue();

    val storage = loadStonfiLpAccountV1StorageFromFork(lpAccount);
    val lpAccountData = lpAccount.getLpAccountData();

    expect(lpAccountData.userAddress).toEqual(storage.userAddress);
    expect(lpAccountData.poolAddress).toEqual(storage.poolAddress);
    expect(lpAccountData.amount0).toEqual(storage.amount0);
    expect(lpAccountData.amount1).toEqual(storage.amount1);
    expectLiveStorage(storage);

    println("STONFI_LP_ACCOUNT_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_LP_ACCOUNT_V1_MAINNET_ADDRESS={}", lpAccount.address);
    println("STONFI_LP_ACCOUNT_V1_MAINNET_STORAGE={}", storage);
    println("STONFI_LP_ACCOUNT_V1_MAINNET_GETTER={}", lpAccountData);
}
