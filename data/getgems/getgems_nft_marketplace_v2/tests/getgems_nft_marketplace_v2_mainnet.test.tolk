import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_marketplace_v2.types"
import "../wrappers/GetgemsNftMarketplaceV2.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_marketplace_v2/testdata/GetgemsNftMarketplaceV2.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xcbd73dced5b4e113234e5b3da1b933f6aad9205b5b8250964bee7a261507de6a
const MAINNET_GETGEMS_NFT_MARKETPLACE_V2_ADDRESS = "EQBYTuYbLf8INxFtD8tQeNk5ZLy-nAX9ahQbG_yl1qQ-GEMS"

fun mainnetGetgemsNftMarketplaceV2(): GetgemsNftMarketplaceV2 {
    return GetgemsNftMarketplaceV2.fromAddress(address(MAINNET_GETGEMS_NFT_MARKETPLACE_V2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyMessageStream(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun loadGetgemsNftMarketplaceV2StorageFromFork(
    marketplace: GetgemsNftMarketplaceV2,
): GetgemsNftMarketplaceV2Storage {
    val account = testing.getAccountState(marketplace.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftMarketplaceV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems marketplace V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems marketplace V2 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems marketplace v2 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("GetgemsNftMarketplaceV2", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems marketplace v2 mainnet getters and storage`() {
    val marketplace = mainnetGetgemsNftMarketplaceV2();
    val storage = loadGetgemsNftMarketplaceV2StorageFromFork(marketplace);

    expect(scripts.isContractDeployed(marketplace.address)).toBeTrue();
    expect(storage.seqno).toEqual(marketplace.seqno());
    expect(storage.publicKey).toEqual(marketplace.getPublicKey());
    expect(marketplace.getPublicKey()).toBeGreater(0);

    println("GETGEMS_NFT_MARKETPLACE_V2_ADDRESS={}", marketplace.address);
    println("GETGEMS_NFT_MARKETPLACE_V2_STORAGE={}", storage);
}

get fun `test getgems marketplace v2 mainnet ignores empty internal message`() {
    val marketplace = mainnetGetgemsNftMarketplaceV2();
    val sender = testing.treasury("getgems-marketplace-v2-empty-internal");
    val beforeSeqno = marketplace.seqno();

    val txs = marketplace.sendAny(
        sender.address,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: marketplace.address,
        exitCode: 0,
    });
    expect(marketplace.seqno()).toEqual(beforeSeqno);
}

get fun `test getgems marketplace v2 mainnet rejects invalid external signature`() {
    val marketplace = mainnetGetgemsNftMarketplaceV2();
    val storage = loadGetgemsNftMarketplaceV2StorageFromFork(marketplace);

    val result = marketplace.sendExternalGetgemsNftMarketplaceV2SignedExternal(
        zeroSignature(),
        storage.subwalletId,
        (blockchain.now() + 1000) as uint32,
        marketplace.seqno(),
        emptyMessageStream(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(
        GetgemsNftMarketplaceV2Errors.ExpiredOrInvalidSignature,
    );
}
