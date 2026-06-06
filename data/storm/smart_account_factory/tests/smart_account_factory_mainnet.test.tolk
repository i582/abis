import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/smart_account_factory.types"
import "../wrappers/SmartAccountFactory.gen"

const PINNED_MAINNET_BLOCK = 71591177
const MAINNET_FACTORY_ADDRESS = "EQA34l2ywiFdu_kb-HZMqLngFVDjw0DJZHo1aBokOap8xVMU"
const MAINNET_FACTORY_ADMIN_ADDRESS = "EQDq2dUBtXoGM7rV555wiA_L1AbaAMDl99QeQaVRiLrV6gP1"
const MAINNET_FACTORY_ITEM_0_ADDRESS = "EQB_5VHXCJRL3DVZhWfnu3AjJoafiTd8rSfGDw68i407FWIT"
const EXPECTED_FACTORY_CODE_HASH =
    0x80f6ccfa2bb13f3914f510e793c651585e5d8d83f80c6bd55869c92524db32c0
const EXPECTED_SMART_ACCOUNT_CODE_HASH =
    0x91beb72642b69dd1217ddf6f488a9391b4d4b83d0131856b1157106091886f56
const EXPECTED_FACTORY_CONTENT_HASH =
    0x96a296d224f285c67bee93c30f8a309157f0daa35dc5b87e410b78630a09cfc7

fun mainnetSmartAccountFactory(): SmartAccountFactory {
    return SmartAccountFactory.fromAddress(address(MAINNET_FACTORY_ADDRESS));
}

fun loadSmartAccountFactoryStorageFromFork(factory: SmartAccountFactory): SmartAccountFactoryStorage {
    val account = testing.getAccountState(factory.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_FACTORY_CODE_HASH);
            return SmartAccountFactoryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("SmartAccountFactory account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("SmartAccountFactory account is frozen");
        }
    }
}

get fun `test smart account factory mainnet storage and getters`() {
    val factory = mainnetSmartAccountFactory();
    val storage = loadSmartAccountFactoryStorageFromFork(factory);
    val factoryData = factory.getFactoryData();
    val minFees = factory.getMinFees();
    val royaltyParams = factory.royaltyParams();
    val item0Address = factory.getNftAddressByIndex(0);

    expect(scripts.isContractDeployed(factory.address)).toBeTrue();
    expect(storage.adminAddress).toEqual(address(MAINNET_FACTORY_ADMIN_ADDRESS));
    expect(factoryData.adminAddress).toEqual(storage.adminAddress);
    expect(factoryData.highloadTimeout).toEqual(storage.highloadTimeout as int);
    expect(factoryData.hotPublicKey).toEqual(storage.hotPublicKey as int);
    expect(factoryData.coldPublicKey).toEqual(storage.coldPublicKey as int);
    expect(factoryData.content.hash()).toEqual(storage.content.hash());
    expect(storage.content.hash()).toEqual(EXPECTED_FACTORY_CONTENT_HASH);
    expect(factoryData.saOrdinaryVersion).toEqual(storage.saOrdinaryVersion);
    expect(factoryData.saOrdinaryCode.hash()).toEqual(storage.saOrdinaryCode.hash());
    expect(storage.saOrdinaryCode.hash()).toEqual(EXPECTED_SMART_ACCOUNT_CODE_HASH);

    expect(minFees.depositMinFeeNative).toEqual(45844676);
    expect(minFees.depositMinFeeJetton).toEqual(46511343);
    expect(minFees.depositWithDeployMinFeeNative).toEqual(99313237);
    expect(minFees.depositWithDeployMinFeeJetton).toEqual(99979904);
    expect(minFees.withdrawMinFee).toEqual(45106810);
    expect(minFees.ordinarySaStorageFee).toEqual(48136960);

    expect(royaltyParams.numerator).toEqual(0);
    expect(royaltyParams.denominator).toEqual(1);
    expect(royaltyParams.royaltyAddress).toEqual(storage.adminAddress);
    expect(item0Address).toEqual(address(MAINNET_FACTORY_ITEM_0_ADDRESS));

    println("STORM_SMART_ACCOUNT_FACTORY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("STORM_SMART_ACCOUNT_FACTORY_ADDRESS={}", factory.address);
    println("STORM_SMART_ACCOUNT_FACTORY_STORAGE={}", storage);
    println("STORM_SMART_ACCOUNT_FACTORY_DATA={}", factoryData);
    println("STORM_SMART_ACCOUNT_FACTORY_MIN_FEES={}", minFees);
    println("STORM_SMART_ACCOUNT_FACTORY_ITEM_0={}", item0Address);
}
