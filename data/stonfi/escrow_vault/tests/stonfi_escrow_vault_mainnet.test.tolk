import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_escrow_vault.types"
import "../wrappers/StonfiEscrowVault.gen"

const FIXTURE_BOC_PATH = "data/stonfi/escrow_vault/testdata/StonfiEscrowVault.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa16ce5a25feb87415b18b9cda9265b5d85328a32219ea47a7f529a8860c0450f
const EXPECTED_DATA_HASH = 0x0372a9b491b0c0041d2a131d92cd9af640e31bc61e5dda7f451e04185c71085b
const EXPECTED_BALANCE = 2084949781
const PINNED_MAINNET_BLOCK = 71167154
const VAULT_ADDRESS = "EQAAhKnQjiJjQnAX75bYFFTj6w9XDu34_wKNvDdPRL6nAH9O"
const MINTER_ADDRESS = "EQAzSd3ZA9X_E5348_RxhVqGhY3kfN6fmS0Qi-XFghbpJrBn"
const JETTON_WALLET_ADDRESS = "EQByY79x2kFjg0QV8Z8Pk9CGTqPx855LiD1cyR3RDP1viD2I"
const OWNER_ADDRESS = "EQA5OfsGL3H7kDN8j3gIUhhRaDhnMFAwZ5GGIRIKPBkQloSf"

fun vault(): StonfiEscrowVault {
    return StonfiEscrowVault.fromAddress(address(VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadVaultStorage(contract: StonfiEscrowVault): StonfiEscrowVaultStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiEscrowVault", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return StonfiEscrowVaultStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Escrow Vault is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Escrow Vault is frozen at the pinned block");
        }
    }
}

get fun `test stonfi escrow vault code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("StonfiEscrowVault", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi escrow vault parses pinned storage and getter`() {
    val contract = vault();
    val storage = loadVaultStorage(contract);
    val data = contract.getVaultData();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.minter).toEqual(address(MINTER_ADDRESS));
    expect(storage.jettonWallet).toEqual(address(JETTON_WALLET_ADDRESS));
    expect(storage.balance).toEqual(EXPECTED_BALANCE);
    expect(storage.owner).toEqual(address(OWNER_ADDRESS));

    expect(data.minter).toEqual(storage.minter);
    expect(data.jettonWallet).toEqual(storage.jettonWallet);
    expect(data.balance).toEqual(storage.balance);
    expect(data.owner).toEqual(storage.owner);

    println("STONFI_ESCROW_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
