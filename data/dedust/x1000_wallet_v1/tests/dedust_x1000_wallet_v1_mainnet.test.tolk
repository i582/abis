import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_x1000_wallet_v1.types"
import "../wrappers/DedustX1000WalletV1.gen"

const WALLET_ADDRESS = "EQDP5uHBEMdxjA_zACkOUZIinRsKFkT-UvFfBRdMpfghVsD_"
const FIXTURE_BOC_PATH = "data/dedust/x1000_wallet_v1/testdata/DedustX1000WalletV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x43d44716d326a832ced56a6b60a02cb67630e04f5785fe89f8784a110cf36151
const EXPECTED_DATA_HASH = 0x1cbbd6f14f7ff7466bd9f17211f99031b152f914cdb98992e0f6826c1335589f
const EXPECTED_SEQNO_BITMAP = 0xf000000000000000000000000000000000000000000000000000000000000000
const EXPECTED_PUBLIC_KEY = 0x7f568dd4e0eca61fdb7148272cd18dfdec463e29a08e01a1a96d1567e8f94875
const PINNED_MAINNET_BLOCK = 52337416

fun wallet(): DedustX1000WalletV1 {
    return DedustX1000WalletV1.fromAddress(address(WALLET_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

get fun `test DeDust x1000 Wallet V1 fixture has exact live code hash`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("DedustX1000WalletV1", FIXTURE_BOC_PATH).hash()).toEqual(
        EXPECTED_CODE_HASH,
    );
}

get fun `test DeDust x1000 Wallet V1 parses pinned storage`() {
    val contract = wallet();
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();

    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(
                build("DedustX1000WalletV1", FIXTURE_BOC_PATH).hash(),
            );
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);

            val storage = DedustX1000WalletV1Storage.fromCell(data!);
            expect(storage.seqnoOffset).toEqual(0);
            expect(storage.seqnoBitmap).toEqual(bits256FromUint(EXPECTED_SEQNO_BITMAP));
            expect(storage.publicKey).toEqual(EXPECTED_PUBLIC_KEY);
            expect(storage.revoked.isEmpty()).toBeTrue();
            println("DEDUST_X1000_WALLET_V1_PINNED_BLOCK={}", PINNED_MAINNET_BLOCK);
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust x1000 Wallet V1 is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust x1000 Wallet V1 is frozen at the pinned block");
        }
    }
}
