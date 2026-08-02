import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tac_jetton.types"
import "../wrappers/TacJetton.gen"

const TAC_JETTON_ADDRESS = "EQBWHKpEx-l1VFDwLCfi8wKkqM4I38pUr0gAUJtJLqyx0-72"
const FIXTURE_BOC_PATH = "data/tac/jetton/testdata/TacJetton.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc74c2ca7311c8c6edcacacc06c319b8c5b4a7be7cc00e7b4ffb7bf78514ce6bf
const EXPECTED_DATA_HASH = 0xbb77f1d1e575ee0519335b37cb29e458b29604ee95f1b82cbba111dd72e1af50
const EXPECTED_EVM_TOKEN_ADDRESS = "0x4183Bd253Dc1918A04Bd8a8dD546BaAD58898109"
const PINNED_MAINNET_BLOCK = 51369544

fun tacJetton(): TacJetton {
    return TacJetton.fromAddress(address(TAC_JETTON_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadTacJettonStorage(contract: TacJetton): TacJettonStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TacJetton", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return TacJettonStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("TAC Jetton is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("TAC Jetton is frozen at the pinned block");
        }
    }
}

get fun `test tac jetton code boc fixture is real and hash verified`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TacJetton", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tac jetton parses pinned storage and getters`() {
    val contract = tacJetton();
    val storage = loadTacJettonStorage(contract);
    val jettonData = contract.getJettonData();
    val fullData = contract.getFullData();
    val evmTokenAddress = contract.getEvmTokenAddress();
    val walletAddress = contract.getWalletAddress(contract.address as any_address);
    val expectedEvmTokenAddress = EXPECTED_EVM_TOKEN_ADDRESS.literalSlice();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.adminAddress).toBeNotNull();
    expect(storage.newAdminAddress).toBeNull();
    expect(storage.evmTokenAddress.remainingBitsCount()).toEqual(336);
    expect(storage.evmTokenAddress.remainingRefsCount()).toEqual(0);
    expect(storage.evmTokenAddress.hash()).toEqual(expectedEvmTokenAddress.hash());

    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress.castToInternal()).toEqual(storage.adminAddress!);
    expect(jettonData.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());

    expect(fullData.totalSupply).toEqual(storage.totalSupply);
    expect(fullData.adminAddress.castToInternal()).toEqual(storage.adminAddress!);
    expect(fullData.newAdminAddress).toBeNoneAddress();
    expect(fullData.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(fullData.jettonWalletCode.hash()).toEqual(storage.jettonWalletCode.hash());
    expect(fullData.evmTokenAddress.hash()).toEqual(expectedEvmTokenAddress.hash());

    expect(evmTokenAddress.remainingBitsCount()).toEqual(336);
    expect(evmTokenAddress.remainingRefsCount()).toEqual(0);
    expect(evmTokenAddress.hash()).toEqual(expectedEvmTokenAddress.hash());
    expect(walletAddress.castToInternal().getWorkchain()).toEqual(0);

    println("TAC_JETTON_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TAC_JETTON_ADDRESS={}", contract.address);
    println("TAC_JETTON_EVM_ADDRESS={}", evmTokenAddress);
}
