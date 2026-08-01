import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/cocoon_wallet.types"
import "../wrappers/CocoonWallet.gen"

const FIXTURE_BOC_PATH = "data/cocoon/wallet/testdata/CocoonWallet.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x7a48f05ceef40f06cabbaa39c1c5a67b24e8bb59d8cf8a74e49988a5f44cf66a
const EXPECTED_DATA_HASH = 0xe9f3f4199ed2cdf6c2a3f587c8232f74ffe72ec3621d08a85b994f51c628db0c
const WALLET_ADDRESS = "EQBGsVa8sS32TOmXMjT2ueLcyEvdzla9RHwB8e9d5mDnxRJS"
const PINNED_MAINNET_BLOCK = 83377290

fun wallet(): CocoonWallet {
    return CocoonWallet.fromAddress(address(WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadWalletStorage(contract: CocoonWallet): CocoonWalletStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("CocoonWallet", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return CocoonWalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("COCOON Wallet is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("COCOON Wallet is frozen at the pinned block");
        }
    }
}

get fun `test cocoon wallet code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("CocoonWallet", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test cocoon wallet parses pinned storage and getters`() {
    val contract = wallet();
    val storage = loadWalletStorage(contract);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status & 1).toEqual(0);
    expect(contract.seqno()).toEqual(storage.seqno);
    expect(contract.getPublicKey()).toEqual(storage.publicKey);
    expect(contract.getOwnerAddress()).toEqual(storage.ownerAddress);
    println("COCOON_WALLET_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
