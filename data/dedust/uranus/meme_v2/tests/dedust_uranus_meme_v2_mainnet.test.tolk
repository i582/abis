import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_uranus_meme_v2.types"
import "../wrappers/DedustUranusMemeV2.gen"

const CODE_FIXTURE_BOC_PATH = "data/dedust/uranus/meme_v2/testdata/DedustUranusMemeV2.boc"
const DATA_FIXTURE_BOC_PATH = "data/dedust/uranus/meme_v2/testdata/DedustUranusMemeV2.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x722d37be518ee0d4b6714077727ed60724bf379e8f1479c220b853d1af3cf00d
const EXPECTED_DATA_HASH = 0x694ffc0f2f538f33cf96400f47795565c7dced3168e9239466a4e1477a9f25f6
const EXPECTED_WALLET_CODE_HASH = 0x21097ae6d15af88099db08eb49b71df933905c86a09c3823fd5f0e1a8b6acdae
const PINNED_MAINNET_BLOCK = 58340099

const MEME_ADDRESS = "EQAO_1qemostkDtMfhp7XU0nOsAkQ_tLUO5YJeNMrj3dRAaH"
const CREATOR_ADDRESS = "0:D4A0253D0688EE4B1292BF17B51FBFFBC8F0F2B0000BFECF9E47590A5E83790D"
const CONTROLLER_ADDRESS = "0:33664F9813E0BFD936B1333362EF5BA92DFC0B601591A5608AE8CD6F85B00EB4"
const CREATOR_WALLET_ADDRESS = "EQDUR-Q4u6FxL7SagNQDT7B-CuWpTHLNrTy20PMHoRuO6ofc"

const BUY_EVENT_BOC_BASE64 = "te6cckEBAQEASAAAi6Cqa8KAGpQEp6DRHcliUlfi9qP3/3keHlYAAX/Z88jrIUvQbyGoU5xIMODnAM4Hm7aGldR8ZANnwA4OcAzgebtohTnEgwgNAQJ9"
const SELL_EVENT_BOC_BASE64 = "te6cckEBAQEASwAAkTqw/MyAGpQEp6DRHcliUlfi9qP3/3keHlYAAX/Z88jrIUvQbyGuDaegTGlZuoTt1b2GjVNWY8kWxnki3A4zAnWASauwko0Fv7BYpaEx"

fun meme(): DedustUranusMemeV2 {
    return DedustUranusMemeV2.fromAddress(address(MEME_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadPinnedStorage(contract: DedustUranusMemeV2): DedustUranusMemeV2Storage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("DedustUranusMemeV2", CODE_FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("DedustUranusMemeV2", DATA_FIXTURE_BOC_PATH).hash());
            return DedustUranusMemeV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Uranus Meme V2 is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Uranus Meme V2 is frozen at the pinned block");
        }
    }
}

get fun `test dedust uranus meme v2 fixtures match pinned mainnet state`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("DedustUranusMemeV2", CODE_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("DedustUranusMemeV2", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test dedust uranus meme v2 parses pinned storage and getters`() {
    val contract = meme();
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    val storage = loadPinnedStorage(contract);
    val config = storage.config.load();

    expect(storage.initialized).toBeTrue();
    expect(storage.migrated).toBeFalse();
    expect(storage.baseFeeBps).toEqual(100);
    expect(storage.curve.graduated).toBeFalse();
    expect(storage.curve.alpha).toEqual(1084745762711864406);
    expect(storage.curve.beta).toEqual(373728813559);
    expect(storage.curve.onSellSupply).toEqual(800000000000000000);
    expect(storage.curve.raisedFunds).toEqual(487713704);
    expect(storage.curve.currentSupply).toEqual(1413741325766464);
    expect(storage.totalSupply).toEqual(1000000000000000000);
    expect(storage.creatorFee).toEqual(32030322);
    expect(config.creatorAddress).toEqual(address(CREATOR_ADDRESS));
    expect(config.controllerAddress).toEqual(address(CONTROLLER_ADDRESS));
    expect(config.raisingFunds).toEqual(1000000000000);
    expect(config.liquidityTokens).toEqual(200000000000000000);
    expect(config.seed).toEqual(227626340246145419163140496618231247965);
    expect(config.metadata.uri).toEqual(
        "ipfs://bafkreibnys6x3wy6zbphjmzengvbdaxrxt3jcil3gvn7oaf2pkqlz5sena",
    );

    val memeData = contract.getMemeData();
    expect(memeData.initialized).toEqual(storage.initialized);
    expect(memeData.migrated).toEqual(storage.migrated);
    expect(memeData.controllerAddress).toEqual(config.controllerAddress);
    expect(memeData.creatorAddress).toEqual(config.creatorAddress);
    expect(memeData.creatorFee).toEqual(storage.creatorFee);
    expect(memeData.seed).toEqual(config.seed);
    expect(memeData.isGraduated).toEqual(storage.curve.graduated);
    expect(memeData.alpha).toEqual(storage.curve.alpha);
    expect(memeData.beta).toEqual(storage.curve.beta);
    expect(memeData.onSellSupply).toEqual(storage.curve.onSellSupply);
    expect(memeData.tradeFeeBps).toEqual(storage.baseFeeBps);
    expect(memeData.raisedFunds).toEqual(storage.curve.raisedFunds);
    expect(memeData.currentSupply).toEqual(storage.curve.currentSupply);

    val jettonData = contract.getJettonData();
    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeFalse();
    expect(jettonData.adminAddress).toBeNoneAddress();
    expect(jettonData.jettonWalletCode.hash()).toEqual(EXPECTED_WALLET_CODE_HASH);
    expect(contract.getWalletAddress(config.creatorAddress)).toEqual(
        address(CREATOR_WALLET_ADDRESS),
    );
}

get fun `test dedust uranus meme v2 decodes real buy and sell events`() {
    val buy = DedustUranusMemeV2BuyEvent.fromCell(parseCellFromBase64(BUY_EVENT_BOC_BASE64));
    expect(buy.traderAddress).toEqual(address(CREATOR_ADDRESS));
    expect(buy.amountIn).toEqual(701375512);
    expect(buy.amountOut).toEqual(2031925140970932);
    expect(buy.fees.creatorFee).toEqual(4909630);
    expect(buy.fees.protocolFee).toEqual(2104126);
    expect(buy.fees.partnerFee).toEqual(0);
    expect(buy.fees.referrerFee).toEqual(0);
    expect(buy.currentSupply).toEqual(2031925140970932);
    expect(buy.raisedFunds).toEqual(701375512);
    expect(buy.isGraduated).toBeFalse();

    val sell = DedustUranusMemeV2SellEvent.fromCell(parseCellFromBase64(SELL_EVENT_BOC_BASE64));
    expect(sell.traderAddress).toEqual(address(CREATOR_ADDRESS));
    expect(sell.amountIn).toEqual(1921740807908573);
    expect(sell.amountOut).toEqual(661564908);
    expect(sell.fees.creatorFee).toEqual(4630955);
    expect(sell.fees.protocolFee).toEqual(1984694);
    expect(sell.fees.partnerFee).toEqual(3969390);
    expect(sell.fees.referrerFee).toEqual(0);
    expect(sell.currentSupply).toEqual(7178963749492184);
    expect(sell.raisedFunds).toEqual(2489855485);
}
