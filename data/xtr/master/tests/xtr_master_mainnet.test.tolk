import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/xtr_master.types"
import "../wrappers/XtrMaster.gen"

const MASTER_ADDRESS = "EQA5Fs0huec9mq2pBbfm17AjAguaoLT6mdBf2jbwxmyTazCn"
const WALLET_OWNER_ADDRESS = "EQAsl59qOy9C2XL5452lGbHU9bI3l4lhRaopeNZ82NRK8nlA"
const OWNER_XTR_WALLET_ADDRESS = "EQBP7107wDRe67Fa2mstvLUoy8B0yTQ6dFFBjHd12p6ATxNB"
const FIXTURE_BOC_PATH = "data/xtr/master/testdata/XtrMaster.boc"
const DATA_FIXTURE_BOC_PATH = "data/xtr/master/testdata/XtrMaster.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xc363366e7ed77d0c08bae1af61634ed3396310ab39a5c3adbaaae7f7e5f3cb26
const EXPECTED_DATA_HASH = 0x4df1a66cbc7e652a16f12ce4236055ee777908f9c04553dc91f3e2e08a703ccb
const PINNED_MAINNET_BLOCK = 80293614

fun master(): XtrMaster {
    return XtrMaster.fromAddress(address(MASTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadMasterStorage(contract: XtrMaster): XtrMasterStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("XtrMaster", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("XtrMaster", DATA_FIXTURE_BOC_PATH).hash());
            return XtrMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("XTR Master is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("XTR Master is frozen at the pinned block");
        }
    }
}

get fun `test xtr master code and data fixtures match mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("XtrMaster", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("XtrMaster", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test xtr master parses pinned storage and getters`() {
    val contract = master();
    val storage = loadMasterStorage(contract);
    val versions = storage.versions.load();
    val userVersion = versions.user.load();
    val paymentVersion = versions.payment.load();
    val userVersionGetter = contract.getUserLatestVersion();
    val paymentVersionGetter = contract.getPaymentLatestVersion();
    val jettonData = contract.getJettonData();
    val walletAddress = contract.getWalletAddress(address(WALLET_OWNER_ADDRESS) as any_address);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(userVersion.version).toEqual(0);
    expect(paymentVersion.version).toEqual(0);
    expect(paymentVersion.seqno).toEqual(19);
    expect(storage.totalSupply).toEqual(355290000000);
    expect(userVersionGetter).toEqual(userVersion.version);
    expect(paymentVersionGetter).toEqual(paymentVersion.version);
    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toEqual(-1);
    expect(jettonData.adminAddress.castToInternal()).toEqual(storage.admin);
    expect(jettonData.jettonContent.hash()).toEqual(storage.jettonContent.hash());
    expect(jettonData.jettonWalletCode.hash()).toEqual(userVersion.jettonWalletCode.hash());
    expect(walletAddress.castToInternal()).toEqual(address(OWNER_XTR_WALLET_ADDRESS));
    println("XTR_MASTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println(
        "XTR_MASTER_USER_VERSION={} PAYMENT_VERSION={} PAYMENT_SEQNO={} SUPPLY={}",
        userVersion.version,
        paymentVersion.version,
        paymentVersion.seqno,
        storage.totalSupply,
    );
}
