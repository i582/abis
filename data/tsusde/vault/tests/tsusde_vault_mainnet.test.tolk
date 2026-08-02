import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/tsusde_vault.types"
import "../wrappers/TsusdeVault.gen"

const CODE_FIXTURE_BOC_PATH = "data/tsusde/vault/testdata/TsusdeVault.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x9d54931c9d43e8699d2382095e8237b5acb1beecaf236d337210acd0b43cd19d
const EXPECTED_DATA_HASH = 0xe0551c758d2013d63c1a239734ab980666b97f82655af760c5060c58a851612d
const EXPECTED_MINT_NANOS = 35000000
const EXPECTED_UNVESTED_AMOUNT = 1567273233
const EXPECTED_TOTAL_ASSETS = 8623626668626
const EXPECTED_ASSET_BALANCE = 8625193941859
const EXPECTED_TOTAL_SHARES = 6832825700362
const PINNED_MAINNET_BLOCK = 54216500
const PINNED_BLOCK_TIMESTAMP = 1763721008
const VAULT_ADDRESS = "EQChGuD1u0e7KUWHH5FaYh_ygcLXhsdG2nSHPXHW8qqnpZXW"

struct LoadedTsusdeVaultStorage {
    /// Original pinned data cell used to verify lossless storage decoding.
    data: cell
    /// Typed LayerZero classlib storage decoded from the original data cell.
    storage: TsusdeVaultStorage
}

fun vault(): TsusdeVault {
    return TsusdeVault.fromAddress(address(VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun zeroClasslibHeader(): bits350 {
    var header = beginCell().storeUint(0, 256).storeUint(0, 94).endCell().beginParse();
    return header.loadBits(350) as bits350;
}

fun loadVaultStorageFromFork(contract: TsusdeVault): LoadedTsusdeVaultStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("TsusdeVault", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return LoadedTsusdeVaultStorage {
                data: data!,
                storage: TsusdeVaultStorage.fromCell(data!),
            };
        }
        TlbAccountStateUninit => {
            Assert.fail("tsUSDe vault is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("tsUSDe vault is frozen at the pinned block");
        }
    }
}

get fun `test tsusde vault code fixture matches live code hash`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("TsusdeVault", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test tsusde vault parses pinned classlib storage and getters`() {
    val contract = vault();
    val loaded = loadVaultStorageFromFork(contract);
    val storage = loaded.storage;
    val baseStorage = storage.baseStorage.load();
    val balances = storage.balances.load();
    val vesting = storage.vesting.load();
    val padding = storage.classlibPadding.beginParse();

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.toCell().hash()).toEqual(loaded.data.hash());
    expect(storage.assetWalletHash).toBeGreater(0);
    expect(storage.shareMinterHash).toBeGreater(0);
    expect(storage.mintNanos).toEqual(EXPECTED_MINT_NANOS);
    expect(baseStorage.ownerHash).toBeGreater(0);
    expect(baseStorage.authenticated).toBeTrue();
    expect(baseStorage.initialized).toBeTrue();
    expect(padding.remainingBitsCount()).toEqual(0);
    expect(padding.remainingRefsCount()).toEqual(0);
    expect(balances.assetBalance).toEqual(EXPECTED_ASSET_BALANCE);
    expect(balances.totalShares).toEqual(EXPECTED_TOTAL_SHARES);
    expect(vesting.vestingAmount).toBeGreater(0);

    testing.setNow(PINNED_BLOCK_TIMESTAMP);
    expect(contract.getMintNanos()).toEqual(EXPECTED_MINT_NANOS);
    expect(contract.getUnvestedAmount()).toEqual(EXPECTED_UNVESTED_AMOUNT);
    expect(contract.getTotalAssets()).toEqual(EXPECTED_TOTAL_ASSETS);
    expect(contract.getTotalShares()).toEqual(EXPECTED_TOTAL_SHARES);
    expect(contract.convertToShares(1000000)).toEqual(792337);
    expect(contract.convertToAssets(1000000)).toEqual(1262087);

    println("TSUSDE_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TSUSDE_VAULT_STORAGE={}", storage);
}

get fun `test tsusde vault recognizes owner management opcode`() {
    val contract = vault();
    val sender = testing.treasury("tsusde-vault-unauthorized-owner");
    val txs = contract.sendTsusdeVaultSetMintNanos(
        sender.address,
        0x1020304050607080,
        0,
        sender.address,
        TsusdeVaultCoinsPayload {
            classlibHeader: zeroClasslibHeader(),
            amount: 1,
        },
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<TsusdeVaultSetMintNanos>({
        from: sender.address,
        to: contract.address,
        exitCode: TsusdeVaultErrors.OnlyOwner,
    });
}
