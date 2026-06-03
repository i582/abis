import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_fixprice_sale_v1.types"
import "../wrappers/GetgemsNftFixpriceSaleV1.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_fixprice_sale_v1/testdata/GetgemsNftFixpriceSaleV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xda9b9fce22e87c496572d20365259579bccef91a720357ccbe8c052efc9be08f
const FULL_PRICE = 2000000000
const MARKETPLACE_FEE = 200000000
const ROYALTY_AMOUNT = 300000000

fun emptyForwardPayload(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun expectBocMagic(mutate bytes: slice): void {
    expect(bytes.remainingBitsCount()).toBeGreater(24);
    expect(bytes.loadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
}

fun getgemsNftFixpriceSaleV1Fees(
    marketplaceFeeAddress: address,
    royaltyAddress: address,
): Cell<GetgemsNftFixpriceSaleV1Fees> {
    return GetgemsNftFixpriceSaleV1Fees {
        marketplaceFee: MARKETPLACE_FEE,
        marketplaceFeeAddress,
        royaltyAddress,
        royaltyAmount: ROYALTY_AMOUNT,
    }.toCell();
}

fun getgemsNftFixpriceSaleV1DeploymentStorage(
    marketplaceAddress: address,
    nftAddress: address,
    marketplaceFeeAddress: address,
    royaltyAddress: address,
): GetgemsNftFixpriceSaleV1DeploymentStorage {
    return {
        marketplaceAddress,
        nftAddress,
        nftOwnerAddress: null,
        fullPrice: FULL_PRICE,
        fees: getgemsNftFixpriceSaleV1Fees(marketplaceFeeAddress, royaltyAddress),
    };
}

fun localGetgemsNftFixpriceSaleV1(
    marketplaceAddress: address,
    nftAddress: address,
    marketplaceFeeAddress: address,
    royaltyAddress: address,
): GetgemsNftFixpriceSaleV1 {
    return GetgemsNftFixpriceSaleV1.fromStorage(
        getgemsNftFixpriceSaleV1DeploymentStorage(
            marketplaceAddress,
            nftAddress,
            marketplaceFeeAddress,
            royaltyAddress,
        ),
    );
}

fun deployLocalGetgemsNftFixpriceSaleV1(
    marketplaceAddress: address,
    nftAddress: address,
    marketplaceFeeAddress: address,
    royaltyAddress: address,
): GetgemsNftFixpriceSaleV1 {
    val sale = localGetgemsNftFixpriceSaleV1(
        marketplaceAddress,
        nftAddress,
        marketplaceFeeAddress,
        royaltyAddress,
    );

    val txs = sale.deploy(marketplaceAddress, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: marketplaceAddress,
        to: sale.address,
        exitCode: 0,
    });
    expect(testing.isDeployed(sale.address)).toBeTrue();

    return GetgemsNftFixpriceSaleV1.fromAddress(sale.address);
}

fun loadGetgemsNftFixpriceSaleV1DeploymentStorage(
    sale: GetgemsNftFixpriceSaleV1,
): GetgemsNftFixpriceSaleV1DeploymentStorage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftFixpriceSaleV1DeploymentStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems fixed-price sale v1 local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems fixed-price sale v1 local fixture account is frozen");
        }
    }
}

fun loadGetgemsNftFixpriceSaleV1Storage(
    sale: GetgemsNftFixpriceSaleV1,
): GetgemsNftFixpriceSaleV1Storage {
    val account = testing.getAccountState(sale.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return GetgemsNftFixpriceSaleV1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems fixed-price sale v1 local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems fixed-price sale v1 local fixture account is frozen");
        }
    }
}

get fun `test getgems sale v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expectBocMagic(mutate bytes);

    val code = build("GetgemsNftFixpriceSaleV1", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems sale v1 local deployment getter and storage`() {
    val marketplace = testing.treasury("getgems-sale-v1-marketplace");
    val nft = testing.treasury("getgems-sale-v1-nft");
    val marketplaceFee = testing.treasury("getgems-sale-v1-marketplace-fee");
    val royalty = testing.treasury("getgems-sale-v1-royalty");
    val sale = deployLocalGetgemsNftFixpriceSaleV1(
        marketplace.address,
        nft.address,
        marketplaceFee.address,
        royalty.address,
    );
    val storage = loadGetgemsNftFixpriceSaleV1DeploymentStorage(sale);
    val fees = storage.fees.load();
    val data = sale.getSaleData();

    expect(data.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(data.nftAddress).toEqual(storage.nftAddress);
    expect(data.nftOwnerAddress).toBeNoneAddress();
    expect(storage.nftOwnerAddress).toBeNull();
    expect(data.fullPrice).toEqual(storage.fullPrice);
    expect(data.marketplaceFeeAddress).toEqual(fees.marketplaceFeeAddress);
    expect(data.marketplaceFee).toEqual(fees.marketplaceFee);
    expect(data.royaltyAddress).toEqual(fees.royaltyAddress);
    expect(data.royaltyAmount).toEqual(fees.royaltyAmount);

    println("GETGEMS_NFT_FIXPRICE_SALE_V1_LOCAL_ADDRESS={}", sale.address);
    println("GETGEMS_NFT_FIXPRICE_SALE_V1_DEPLOYMENT_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V1_DEPLOYMENT_DATA={}", data);
}

get fun `test getgems sale v1 local ownership assigned initializes sale`() {
    val marketplace = testing.treasury("getgems-sale-v1-init-marketplace");
    val nft = testing.treasury("getgems-sale-v1-init-nft");
    val owner = testing.treasury("getgems-sale-v1-init-owner");
    val marketplaceFee = testing.treasury("getgems-sale-v1-init-marketplace-fee");
    val royalty = testing.treasury("getgems-sale-v1-init-royalty");
    val sale = deployLocalGetgemsNftFixpriceSaleV1(
        marketplace.address,
        nft.address,
        marketplaceFee.address,
        royalty.address,
    );

    val initTxs = sale.sendGetgemsNftFixpriceSaleV1OwnershipAssigned(
        nft.address,
        17,
        owner.address,
        emptyForwardPayload(),
        { value: ton("0.05"), bounce: false },
    );
    expect(initTxs).toHaveSuccessfulTx<GetgemsNftFixpriceSaleV1OwnershipAssigned>({
        from: nft.address,
        to: sale.address,
        exitCode: 0,
    });

    val storage = loadGetgemsNftFixpriceSaleV1Storage(sale);
    val data = sale.getSaleData();

    expect(storage.nftOwnerAddress).toEqual(owner.address);
    expect(data.nftOwnerAddress.castToInternal()).toEqual(owner.address);
    expect(data.fullPrice).toEqual(storage.fullPrice);
    expect(data.marketplaceAddress).toEqual(storage.marketplaceAddress);
    expect(data.nftAddress).toEqual(storage.nftAddress);

    println("GETGEMS_NFT_FIXPRICE_SALE_V1_RUNTIME_STORAGE={}", storage);
    println("GETGEMS_NFT_FIXPRICE_SALE_V1_RUNTIME_DATA={}", data);
}

get fun `test getgems sale v1 local rejects unauthorized init and underfunded buy`() {
    val marketplace = testing.treasury("getgems-sale-v1-reject-marketplace");
    val nft = testing.treasury("getgems-sale-v1-reject-nft");
    val owner = testing.treasury("getgems-sale-v1-reject-owner");
    val rogue = testing.treasury("getgems-sale-v1-reject-rogue");
    val buyer = testing.treasury("getgems-sale-v1-reject-buyer");
    val marketplaceFee = testing.treasury("getgems-sale-v1-reject-marketplace-fee");
    val royalty = testing.treasury("getgems-sale-v1-reject-royalty");
    val sale = deployLocalGetgemsNftFixpriceSaleV1(
        marketplace.address,
        nft.address,
        marketplaceFee.address,
        royalty.address,
    );

    val rogueTxs = sale.sendGetgemsNftFixpriceSaleV1OwnershipAssigned(
        rogue.address,
        18,
        owner.address,
        emptyForwardPayload(),
        { value: ton("0.05"), bounce: false },
    );
    expect(rogueTxs).toHaveFailedTx<GetgemsNftFixpriceSaleV1OwnershipAssigned>({
        from: rogue.address,
        to: sale.address,
        exitCode: GetgemsNftFixpriceSaleV1Errors.UnauthorizedInitiation,
    });
    expect(loadGetgemsNftFixpriceSaleV1DeploymentStorage(sale).nftOwnerAddress).toBeNull();

    val initTxs = sale.sendGetgemsNftFixpriceSaleV1OwnershipAssigned(
        nft.address,
        19,
        owner.address,
        emptyForwardPayload(),
        { value: ton("0.05"), bounce: false },
    );
    expect(initTxs).toHaveSuccessfulTx<GetgemsNftFixpriceSaleV1OwnershipAssigned>({
        from: nft.address,
        to: sale.address,
        exitCode: 0,
    });

    val buyTxs = sale.sendGetgemsNftFixpriceSaleV1Buy(
        buyer.address,
        20,
        { value: ton("0.5"), bounce: false },
    );
    expect(buyTxs).toHaveFailedTx<GetgemsNftFixpriceSaleV1Buy>({
        from: buyer.address,
        to: sale.address,
        exitCode: GetgemsNftFixpriceSaleV1Errors.NotEnoughTonsForSale,
    });
}
