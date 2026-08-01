import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/grambo_jetton_wallet.types"
import "../wrappers/GramboJettonWallet.gen"

const WALLET_ADDRESS = "EQCI95BVEikEt6g3ksm4W-HEPP8FMUa_Bi3f7r1CPQJlxGdv"
const FIXTURE_BOC_PATH = "data/grambo/jetton_wallet/testdata/GramboJettonWallet.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa9879cae0815190084adbbdf5a9be7816e7215e0fdc9a22c6dcdf1540b83e36f
const EXPECTED_DATA_HASH = 0xb5ba49faa6f0e7df77f287161f76c0aeef48837a691fa6445d0d043cf34c732a
const PINNED_MAINNET_BLOCK = 83374906

fun wallet(): GramboJettonWallet {
    return GramboJettonWallet.fromAddress(address(WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadWalletStorage(contract: GramboJettonWallet): GramboJettonWalletStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("GramboJettonWallet", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return GramboJettonWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Grambo Jetton Wallet is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Grambo Jetton Wallet is frozen at the pinned block");
        }
    }
}

get fun `test grambo wallet code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("GramboJettonWallet", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test grambo wallet parses pinned storage and getters`() {
    val contract = wallet();
    val storage = loadWalletStorage(contract);
    val getter = contract.getWalletData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.balance).toEqual(getter.balance);
    expect(storage.owner).toEqual(getter.ownerAddress.castToInternal());
    expect(storage.master).toEqual(getter.jettonMasterAddress.castToInternal());
    expect(getter.jettonWalletCode.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(contract.getWalletStatus()).toEqual(storage.activated);
    println("GRAMBO_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
