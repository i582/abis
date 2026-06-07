import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_marketplace_v1.types"
import "../wrappers/GetgemsNftMarketplaceV1.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_marketplace_v1/testdata/GetgemsNftMarketplaceV1.boc"
const MAINNET_GETGEMS_NFT_MARKETPLACE_V1_ADDRESS = "EQB-zPGEJ4FA2fG0DOQhYBziP4RVr5y7w14DnmAQ9aG0lwyp"
const MAINNET_GETGEMS_NFT_MARKETPLACE_V1_OWNER = "EQBpfwA2TL-kq8cvjTT33ti92DT6dASd83b486WNFasIZ6k5"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x76c11e701480f7a66d6368d0e7b570f4f9119f2338568f9d63ff8d12ebf8a0f7

fun mainnetGetgemsNftMarketplaceV1(): GetgemsNftMarketplaceV1 {
    return GetgemsNftMarketplaceV1.fromAddress(address(MAINNET_GETGEMS_NFT_MARKETPLACE_V1_ADDRESS));
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun loadGetgemsNftMarketplaceV1StorageFromFork(
    marketplace: GetgemsNftMarketplaceV1,
): GetgemsNftMarketplaceV1Storage {
    val account = testing.getAccountState(marketplace.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftMarketplaceV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT marketplace V1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT marketplace V1 mainnet fixture account is frozen");
        }
    }
}

fun expectGetgemsNftMarketplaceV1CodeFromFork(marketplace: GetgemsNftMarketplaceV1): void {
    val account = testing.getAccountState(marketplace.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("GetgemsNftMarketplaceV1").hash());
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT marketplace V1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT marketplace V1 mainnet fixture account is frozen");
        }
    }
}

get fun `test getgems marketplace v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("GetgemsNftMarketplaceV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems marketplace v1 mainnet code and storage`() {
    val marketplace = mainnetGetgemsNftMarketplaceV1();
    val storage = loadGetgemsNftMarketplaceV1StorageFromFork(marketplace);

    expect(scripts.isContractDeployed(marketplace.address)).toBeTrue();
    expectGetgemsNftMarketplaceV1CodeFromFork(marketplace);
    expect(storage.ownerAddress).toEqual(address(MAINNET_GETGEMS_NFT_MARKETPLACE_V1_OWNER));

    println("GETGEMS_NFT_MARKETPLACE_V1_ADDRESS={}", marketplace.address);
    println("GETGEMS_NFT_MARKETPLACE_V1_STORAGE={}", storage);
}
