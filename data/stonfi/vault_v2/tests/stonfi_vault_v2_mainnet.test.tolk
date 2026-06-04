import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/stonfi_vault_v2.types"
import "../wrappers/StonfiVaultV2.gen"

const FIXTURE_BOC_PATH = "data/stonfi/vault_v2/testdata/StonfiVaultV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xe2ade46f07c5a715a13f949236df452a5267385ce9af42efcdac2bfc883fb2d2
const PINNED_MAINNET_BLOCK = 71167154

const MAINNET_STONFI_VAULT_V2_ADDRESS = "EQBCFLAnWCc_heRtp78zmT_1h2XhyX7wcEwaiNHry27Mtxw6"

fun mainnetStonfiVaultV2(): StonfiVaultV2 {
    return StonfiVaultV2.fromAddress(address(MAINNET_STONFI_VAULT_V2_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadStonfiVaultV2StorageFromFork(vault: StonfiVaultV2): StonfiVaultV2Storage {
    val account = testing.getAccountState(vault.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("StonfiVaultV2", FIXTURE_BOC_PATH).hash());
            return StonfiVaultV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("STON.fi Vault v2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("STON.fi Vault v2 mainnet fixture account is frozen");
        }
    }
}

get fun `test stonfi vault v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val code = build("StonfiVaultV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test stonfi vault v2 mainnet getter matches fork storage`() {
    val vault = mainnetStonfiVaultV2();
    expect(scripts.isContractDeployed(vault.address)).toBeTrue();

    val storage = loadStonfiVaultV2StorageFromFork(vault);
    val vaultData = vault.getVaultData();

    expect(vaultData.ownerAddress).toEqual(storage.ownerAddress);
    expect(vaultData.tokenAddress).toEqual(storage.tokenAddress);
    expect(vaultData.routerAddress).toEqual(storage.routerAddress);
    expect(vaultData.depositedAmount).toEqual(storage.depositedAmount);

    println("STONFI_VAULT_V2_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STONFI_VAULT_V2_ADDRESS={}", vault.address);
    println("STONFI_VAULT_V2_STORAGE={}", storage);
    println("STONFI_VAULT_V2_VAULT_DATA={}", vaultData);
}
