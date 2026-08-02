import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/telegram_gift_nft_item.types"
import "../wrappers/TelegramGiftNftItem.gen"

const CODE_V2_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem.boc"
const DATA_V2_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem_8b711e68.data.boc"
const LIBRARY_V2_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem_8b711e68.library.boc"
const CODE_V1_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem_30dcd7d5.boc"
const DATA_V1_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem_30dcd7d5.data.boc"
const LIBRARY_V1_PATH = "data/telemint/telegram_gift_nft_item/testdata/TelegramGiftNftItem_30dcd7d5.library.boc"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const CODE_HASH_V2 = 0x8b711e6809672c0335dc61d1da1dcc4059c973248af707bd586245085ea70b32
const DATA_HASH_V2 = 0x936ef83c7f3c0565d1d43d0678e776e94bf088a7e8b30f1fc8aa58aeb7715548
const LIBRARY_HASH_V2 = 0x2498bd63f3e9cc2c20c79abe58899a4816ea156855b8d4fcd47cda4bae9e911a
const CODE_HASH_V1 = 0x30dcd7d5b6fcf5968c2791e1e31ad732f2672f2986e1d6970eb03cca22d23251
const DATA_HASH_V1 = 0x85c49cb43d460e1156eac99685b0e9c2a405d2be44584ef9ce2aa3c5b14ea0f0
const LIBRARY_HASH_V1 = 0x91d9e2ac169fc785ce00de0a81af27622b9b7d1764415c775e7e50c03ce98aa2
const PINNED_MAINNET_BLOCK = 50502689

const ITEM_V2_ADDRESS = "EQDKDP1Rn3YxArW-ydnjr0NZLqNi-3c_oxnqCcTxYsFx4IUQ"
const COLLECTION_V2_ADDRESS = "EQBMcfMAZlMUr1W3X8kdEw3fJMUAaWH4-XcmE5R5RfFIY0E2"
const ITEM_V1_ADDRESS = "EQCYes1qwzGAo1SI75JGWMgy6lgEKU6jv_VaM7FxJE3QrGzu"
const COLLECTION_V1_ADDRESS = "EQADXRgKppGLnz2XVt6n1ZnLkIKQ4Y_uFM1LB4jcK2DO10bq"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadFixture(name: string, path: string): cell {
    val bytes = fs.readBytes(path);
    expect(bytes).toBeNotNull();
    expect(hasBocMagic(bytes!)).toBeTrue();
    return build(name, path);
}

fun verifyPinnedItem(
    itemAddress: address,
    collectionAddress: address,
    expectedCodeHash: int,
    expectedDataHash: int,
    expectedTokenName: string,
): TelegramGiftNftItemStorage {
    val item = TelegramGiftNftItem.fromAddress(itemAddress);
    expect(scripts.isContractDeployed(item.address)).toBeTrue();

    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(expectedCodeHash);
            expect(data!.hash()).toEqual(expectedDataHash);

            val storage = TelegramGiftNftItemStorage.fromCell(data!);
            val config = storage.config.load();
            val state = storage.state!.load();
            val nftData = item.getNftData();
            val auctionConfig = item.getTelemintAuctionConfig();
            val royalty = item.royaltyParams();
            val storedRoyalty = state.royaltyParams.load();

            expect(storage.toCell().hash()).toEqual(data!.hash());
            expect(config.collectionAddress).toEqual(collectionAddress);
            expect(nftData.isInitialized).toBeTrue();
            expect(nftData.itemIndex).toEqual(config.itemIndex as int);
            expect(nftData.collectionAddress).toEqual(config.collectionAddress);
            expect(nftData.ownerAddress.castToInternal()).toEqual(state.ownerAddress!);
            expect(nftData.content).toBeNotNull();
            expect(nftData.content!.hash()).toEqual(state.content.load().nftContent.hash());
            expect(item.getTelemintTokenName()).toEqual(expectedTokenName);
            expect(royalty.numerator).toEqual(storedRoyalty.numerator);
            expect(royalty.denominator).toEqual(storedRoyalty.denominator);
            expect(royalty.destination.castToInternal()).toEqual(storedRoyalty.destination!);
            expect(auctionConfig.beneficiaryAddress).toBeNull();
            expect(auctionConfig.initialMinBid).toEqual(0);
            expect(auctionConfig.maxBid).toEqual(0);
            expect(auctionConfig.minBidStep).toEqual(0);
            expect(auctionConfig.minExtendTime).toEqual(0);
            expect(auctionConfig.duration).toEqual(0);

            return storage;
        }
        TlbAccountStateUninit => {
            Assert.fail("Telegram Gift NFT item is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Telegram Gift NFT item is frozen at the pinned block");
        }
    }
}

fun inlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

get fun `test telegram gift exact code data and library fixtures`() {
    val codeV2 = loadFixture("TelegramGiftNftItem", CODE_V2_PATH);
    val dataV2 = loadFixture("TelegramGiftNftItemDataV2", DATA_V2_PATH);
    val libraryV2 = loadFixture("TelegramGiftNftItemLibraryV2", LIBRARY_V2_PATH);
    val codeV1 = loadFixture("TelegramGiftNftItem", CODE_V1_PATH);
    val dataV1 = loadFixture("TelegramGiftNftItemDataV1", DATA_V1_PATH);
    val libraryV1 = loadFixture("TelegramGiftNftItemLibraryV1", LIBRARY_V1_PATH);

    expect(codeV2.hash()).toEqual(CODE_HASH_V2);
    expect(dataV2.hash()).toEqual(DATA_HASH_V2);
    expect(libraryV2.hash()).toEqual(LIBRARY_HASH_V2);
    expect(codeV1.hash()).toEqual(CODE_HASH_V1);
    expect(dataV1.hash()).toEqual(DATA_HASH_V1);
    expect(libraryV1.hash()).toEqual(LIBRARY_HASH_V1);

    val storageV2 = TelegramGiftNftItemStorage.fromCell(dataV2);
    val storageV1 = TelegramGiftNftItemStorage.fromCell(dataV1);
    expect(storageV2.toCell().hash()).toEqual(dataV2.hash());
    expect(storageV1.toCell().hash()).toEqual(dataV1.hash());
    expect(storageV2.config.load().collectionAddress).toEqual(address(COLLECTION_V2_ADDRESS));
    expect(storageV1.config.load().collectionAddress).toEqual(address(COLLECTION_V1_ADDRESS));
}

get fun `test telegram gift revisions parse pinned storage and getters`() {
    val storageV2 = verifyPinnedItem(
        address(ITEM_V2_ADDRESS),
        address(COLLECTION_V2_ADDRESS),
        CODE_HASH_V2,
        DATA_HASH_V2,
        "deskcalendar-45754",
    );
    val storageV1 = verifyPinnedItem(
        address(ITEM_V1_ADDRESS),
        address(COLLECTION_V1_ADDRESS),
        CODE_HASH_V1,
        DATA_HASH_V1,
        "peppermint",
    );

    println("TELEGRAM_GIFT_PINNED_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("TELEGRAM_GIFT_V2_STORAGE={}", storageV2);
    println("TELEGRAM_GIFT_V1_STORAGE={}", storageV1);
}

get fun `test telegram gift static-data and unauthorized transfer dispatch`() {
    val item = TelegramGiftNftItem.fromAddress(address(ITEM_V2_ADDRESS));
    val sender = testing.treasury("telegram-gift-nft-item-dispatch");
    val before = item.getNftData();

    val staticTxs = item.sendTelegramGiftNftItemGetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );
    expect(staticTxs).toHaveSuccessfulTx<TelegramGiftNftItemGetStaticData>({
        from: sender.address,
        to: item.address,
        exitCode: 0,
    });

    val transferTxs = item.sendTelegramGiftNftItemTransfer(
        sender.address,
        2,
        sender.address,
        sender.address,
        null,
        0,
        inlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );
    expect(transferTxs).toHaveFailedTx<TelegramGiftNftItemTransfer>({
        from: sender.address,
        to: item.address,
        exitCode: Errors.ForbiddenTransfer,
    });
    expect(item.getNftData().ownerAddress).toEqual(before.ownerAddress);
}
