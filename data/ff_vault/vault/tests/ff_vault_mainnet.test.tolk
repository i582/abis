import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/message"
import "@acton/types/transaction"
import "../types/ff_vault.types"
import "../wrappers/FfVault.gen"

const FIXTURE_BOC_PATH = "data/ff_vault/vault/testdata/FfVault.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x84a329794f85d2cb99d5bede2ecf5471597477afa9680935f8869a2a9395ceaf
const EXPECTED_DATA_HASH = 0x2c6cf9308e0d401d02bbdc4607662057f475926c2259d9770e7ba6b32b3778f4
const EXPECTED_DISTRIBUTED_STABLES = 227050174430635989259679729521900975809
const EXPECTED_POSITION_ZERO = "EQDOlO7GZ1VL5NZpP73eDHFgyj8SqzdJQbcnCTTSSL0RDZ4t"
const PINNED_MAINNET_BLOCK = 83373780
const VAULT_ADDRESS = "EQBMTi0nonch8rj6P5mT4TyWlunXAbL0mPmBKU7OKv3t2koO"
const ADMIN_ADDRESS = "EQAjvqocZhXvZrGugQBAQRwKh-geQyJzjeQvRdMRfRn7v4qV"
const PYTH_ORACLE_ADDRESS = "EQA5NPyjfZztDm8jcTBwTAU9NGsgJEkw19z61yecX0TlseSB"
const ASSET_WALLET_ADDRESS = "EQDLnt2Q7uCUGTYKfPK6OoLp8VjcCMrzCrCkGpP6L2TIywXJ"
const STABLE_WALLET_ADDRESS = "EQAf8z8-rQLu8ymuEzOS3GKgptnjMsVefrxAPpSAD-cvGnx7"

fun vault(): FfVault {
    return FfVault.fromAddress(address(VAULT_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadVaultStorage(contract: FfVault): FfVaultStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("FfVault", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return FfVaultStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("FF Vault is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("FF Vault is frozen at the pinned block");
        }
    }
}

get fun `test ff vault code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("FfVault", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test ff vault parses pinned storage and all getters`() {
    val contract = vault();
    val storage = loadVaultStorage(contract);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.assetStaked).toEqual(169820);
    expect(storage.distributedStables).toEqual(EXPECTED_DISTRIBUTED_STABLES);
    expect(storage.maxPriceChange).toEqual(100);
    expect(storage.nextItemIndex).toEqual(6);
    expect(storage.admin).toEqual(address(ADMIN_ADDRESS));
    expect(storage.assetAmountOnVault).toEqual(169820);
    expect(storage.stableAmountOnVault).toEqual(100000);
    val staticData = storage.staticData.load();
    expect(staticData.pythOracle).toEqual(address(PYTH_ORACLE_ADDRESS));
    expect(staticData.assetJettonWallet).toEqual(address(ASSET_WALLET_ADDRESS));
    expect(staticData.stableJettonWallet).toEqual(address(STABLE_WALLET_ADDRESS));
    expect(staticData.stableDecimals).toEqual(6);
    expect(staticData.assetDecimals).toEqual(6);

    val collection = contract.getCollectionData();
    expect(collection.nextItemIndex).toEqual(storage.nextItemIndex);
    expect(collection.content.beginParse().remainingBitsCount() > 0).toBeTrue();
    expect(contract.getNftAddressByIndex(0)).toEqual(address(EXPECTED_POSITION_ZERO));

    val staking = contract.getStakingData();
    expect(staking.tokensStaked).toEqual(storage.assetStaked);
    expect(staking.distributedStables).toEqual(storage.distributedStables);
    expect(staking.maxPriceChange).toEqual(storage.maxPriceChange);

    val balance = contract.getBalance();
    expect(balance.assetAmount).toEqual(storage.assetAmountOnVault);
    expect(balance.stableAmount).toEqual(storage.stableAmountOnVault);

    val nftContent = contract.getNftContent(0, createEmptyCell());
    expect(nftContent.beginParse().remainingBitsCount() > 0).toBeTrue();
    println("FF_VAULT_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}

get fun `test ff vault embeds unstake operation in pinned pyth request`() {
    val contract = vault();
    val queryId = 0x1020304050607080;
    val amountToUnstake = 17;
    val itemIndex = 0;
    val priceUpdateData = beginCell().storeUint(0xA5, 8).endCell();
    val result = testing.processSingleTraceStep(
        address(ADMIN_ADDRESS),
        createMessage({
            bounce: false,
            value: ton("1"),
            dest: contract.address,
            body: FfVaultUnstakeExecute { queryId, priceUpdateData, amountToUnstake, itemIndex },
        }),
    );

    expect(result.outMessages.size()).toEqual(1);
    val request = result.outMessages.at<FfVaultPythParsePriceFeedUpdates>(0).loadBody();
    val operation = FfVaultUnstakeOperation.fromCell(request.operation);
    var rawOperation = request.operation.beginParse();

    expect(rawOperation.loadUint(32)).toEqual(0x97004D72);
    expect(rawOperation.loadUint(64)).toEqual(queryId);
    expect(rawOperation.loadCoins()).toEqual(amountToUnstake);
    expect(rawOperation.loadUint(64)).toEqual(itemIndex);
    expect(rawOperation.remainingBitsCount()).toEqual(0);
    expect(rawOperation.remainingRefsCount()).toEqual(0);
    expect(operation.queryId).toEqual(queryId);
    expect(operation.amountToUnstake).toEqual(amountToUnstake);
    expect(operation.itemIndex).toEqual(itemIndex);
    expect(request.targetAddress.castToInternal()).toEqual(contract.address);
}
