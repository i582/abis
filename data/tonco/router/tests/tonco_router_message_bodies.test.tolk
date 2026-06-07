import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonco_router.types"

const TONCO_ROUTER_SWAP_TX = "7QMVPIg9HUDKx+19ZIPv2gmc+m9kd/spHRvdahOEKow="
const TONCO_ROUTER_SWAP_LT = "81584344000007"
const TONCO_ROUTER_PAY_TO_TX = "Qe7svJgdShiY1be5yX9uwtcaRGhouEroPWR+dG9oWaM="
const TONCO_ROUTER_PAY_TO_LT = "81584344000011"
const TONCO_ROUTER_FUND_TX = "jzFaqvOQw24Wv66ExCDgrZkNxmHFRbqPQmnNdSSP8Ag="
const TONCO_ROUTER_FUND_LT = "81583889000013"

const TONCO_ROUTER_USER = "0:74F3AB23BFC7F08B30EA90C30B0FB7CD88CFCFD1BE84DC187EBFC95762343D30"
const TONCO_ROUTER_SWAP_SOURCE_WALLET = "0:34D27AF3B8CE40EFE6346804C369B109AF6D892911C574C939D214C6BAB22E3E"
const TONCO_ROUTER_SWAP_TARGET_WALLET = "0:871DA9215B14902166F0EA2A16DB56278D528108377F8158C5F4CCFDFDD22E17"
const TONCO_ROUTER_FUND_OWNER = "0:C82D3A87108A2ED440FEE6763EB9CB6BD7BA8A9DC433D01FBB2476FC9B0A216E"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(payload);
    return payloadCell;
}

get fun `test tonco router decodes toncenter swap jetton notification body`() {
    val bodyBoc = "te6cckEBAgEAmQABaHNi0Jw67OBLPlqtMGBIwnOVAAgA6edWR3+P4RZh1SGGFh9vmxGfn6N9Cbgw/X+SrsRoemEBAL+n+1j4gBDjtSQrYpIELN4dRULbasTxqlAhBu/wKxi+mZ+/ukXC4AAAAAAAAAAAAAAAAAAAACAATtSJHmJYIQAdPOrI7/H8Isw6pDDCw+3zYjPz9G+hNwYfr/JV2I0PTBASeH8t";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = JettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val swapPayload = ToncoPoolSwapForwardPayload.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(4246015162476834096);
    expect(decoded.jettonAmount).toEqual(5000000000000);
    expect(decoded.fromUser).toEqual(address(TONCO_ROUTER_USER));
    expect(swapPayload.targetJettonWallet).toEqual(address(TONCO_ROUTER_SWAP_TARGET_WALLET));
    expect(swapPayload.sqrtPriceLimitX96).toEqual(4295128740);
    expect(swapPayload.minOutAmount).toEqual(2402364432);
    expect(swapPayload.ownerAddress).toEqual(address(TONCO_ROUTER_USER));
    expect(swapPayload.multihopCell).toBeNull();
    expect(swapPayload.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_ROUTER_SWAP_JETTON_NOTIFY_TX={} LT={}",
        TONCO_ROUTER_SWAP_TX,
        TONCO_ROUTER_SWAP_LT,
    );
}

get fun `test tonco router decodes toncenter pay to body`() {
    val bodyBoc = "te6cckECBAEAARcAArah2qltOuzgSz5arTCADp51ZHf4/hFmHVIYYWH2+bEZ+fo30JuDD9f5KuxGh6YQAdPOrI7/H8Isw6pDDCw+3zYjPz9G+hNwYfr/JV2I0PTAAAADIAAAAAAAARgzAQIBjwgAaaT153Gcgd/MaNAJhtNiE17bElIjiumSc6QpjXVkXHyS10/nUAIcdqSFbFJAhZvDqKhbbVieNUoEIN3+BWMX0zP390i4XgMAzgAAAAAAAAAAAAAYceUPVrEAAAAAAAAAAAXA+8hPmiKXhkk1mP7XegAAAAAAAAAAAAAAAAAAAAkbewx8URXzIEiyTWfFkomtAAAAAAAAAAAAAAAAAAAAAACsVocAFKZ7BDtZzlNtplsAAwAgPC94dw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Routerv3PayTo.fromCell(body);
    val payTo = decoded.payTo;

    expect(decoded.queryId).toEqual(4246015162476834096);
    expect(decoded.receiver0).toEqual(address(TONCO_ROUTER_USER));
    expect(decoded.receiver1).toEqual(address(TONCO_ROUTER_USER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    match (payTo) {
        PayToCode0 => {
            expect(false).toBeTrue();
        }
        PayToCode200 => {
            expect(payTo.seqno).toEqual(17932);
            expect(payTo.coinsinfoCell).toBeNotNull();
            expect(payTo.indexerSwapInfoCell).toBeNotNull();

            val coinsinfo = payTo.coinsinfoCell!.load();
            val payload = coinsinfo.payloadCell.load();
            val indexer = payTo.indexerSwapInfoCell!.load();

            expect(coinsinfo.amount0).toEqual(0);
            expect(coinsinfo.jetton0Address).toEqual(address(TONCO_ROUTER_SWAP_SOURCE_WALLET));
            expect(coinsinfo.amount1).toEqual(2528804666);
            expect(coinsinfo.jetton1Address).toEqual(address(TONCO_ROUTER_SWAP_TARGET_WALLET));
            expect(payload.payloadAmount0).toEqual(0);
            expect(payload.payloadCell0).toBeNull();
            expect(payload.payloadAmount1).toEqual(0);
            expect(payload.payloadCell1).toBeNull();
            expect(indexer.liquidity).toEqual(26877453358769);
            expect(indexer.priceSqrt).toEqual(1780727815544684277624550808);
            expect(indexer.tick).toEqual(-75910);
            expect(indexer.feeGrowthGlobal0X128).toEqual(3099069363926540900494236797414988220845);
            expect(indexer.feeGrowthGlobal1X128).toEqual(894830042720808519932186114019665499);
        }
        PayToCode201 => {
            expect(false).toBeTrue();
        }
        PayToCode230 => {
            expect(false).toBeTrue();
        }
    }

    println("TONCO_ROUTER_PAY_TO_TX={} LT={}", TONCO_ROUTER_PAY_TO_TX, TONCO_ROUTER_PAY_TO_LT);
}

get fun `test tonco router decodes toncenter outgoing pool swap body`() {
    val bodyBoc = "te6cckEBAwEAmQACnaf7WPg67OBLPlqtMIAOnnVkd/j+EWYdUhhhYfb5sRn5+jfQm4MP1/kq7EaHphAA00nrzuM5A7+Y0aATDabEJr22JKRHFdMk50hTGurIuPoBAgA+YEjCc5UAAAAAAAAAAAAAAAAAAAAAABAAJ2pEjzEsEABFgA6edWR3+P4RZh1SGGFh9vmxGfn6N9Cbgw/X+SrsRoemAARiZmlQ";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Swap.fromCell(body);
    val params = decoded.paramsCell.load();
    val payloads = decoded.payloadsCell.load();

    expect(decoded.queryId).toEqual(4246015162476834096);
    expect(decoded.ownerAddress).toEqual(address(TONCO_ROUTER_USER));
    expect(decoded.sourceWallet).toEqual(address(TONCO_ROUTER_SWAP_SOURCE_WALLET));
    expect(params.amount).toEqual(5000000000000);
    expect(params.sqrtPriceLimitX96).toEqual(4295128740);
    expect(params.minOutAmount).toEqual(2402364432);
    expect(payloads.targetAddress).toEqual(address(TONCO_ROUTER_USER));
    expect(payloads.okForwardAmount).toEqual(0);
    expect(payloads.okForwardPayload).toBeNull();
    expect(payloads.retForwardAmount).toEqual(0);
    expect(payloads.retForwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_ROUTER_POOL_SWAP_TX={} LT={}", TONCO_ROUTER_SWAP_TX, TONCO_ROUTER_SWAP_LT);
}

get fun `test tonco router decodes toncenter fund account jetton notification body`() {
    val bodyBoc = "te6cckEBAgEAfQABZHNi0JwAAAAAAAAAAEA2NB0YAZBadQ4hFF2ogf3M7H1zltevdRU7iGegP3ZI7fk2FELdAQCLRGjed4AQ47UkK2KSBCzeHUVC22rE8apQIQbv8CsYvpmfv7pFwugGtVc+oXMFC65AAAAAAAAAAAAAAABhxa3o39+gn+JaENkzuqc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = JettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadForwardPayloadRef(mutate forwardPayload);
    val fundPayload = ToncoPoolFundAccountPayload.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.jettonAmount).toEqual(56836561);
    expect(decoded.fromUser).toEqual(address(TONCO_ROUTER_FUND_OWNER));
    expect(fundPayload.jettonTargetWallet).toEqual(address(TONCO_ROUTER_SWAP_TARGET_WALLET));
    expect(fundPayload.enough0).toEqual(56273823);
    expect(fundPayload.enough1).toEqual(49797422450);
    expect(fundPayload.liquidity).toEqual(13122760518);
    expect(fundPayload.tickLower).toEqual(-66300);
    expect(fundPayload.tickUpper).toEqual(-60720);
    expect(fundPayload.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_ROUTER_FUND_JETTON_NOTIFY_TX={} LT={}",
        TONCO_ROUTER_FUND_TX,
        TONCO_ROUTER_FUND_LT,
    );
}

get fun `test tonco router decodes toncenter outgoing pool fund account body`() {
    val bodyBoc = "te6cckEBAQEAVQAApURo3ncAAAAAAAAAAIAZBadQ4hFF2ogf3M7H1zltevdRU7iGegP3ZI7fk2FELcCAbGg6KhcwULrkgGtVc+AAAAAAAAAAAAAAAGHFrejf36Cf4loQTQ5z5g==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3FundAccount.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.ownerAddr).toEqual(address(TONCO_ROUTER_FUND_OWNER));
    expect(decoded.amount0).toEqual(0);
    expect(decoded.amount1).toEqual(56836561);
    expect(decoded.enough0).toEqual(49797422450);
    expect(decoded.enough1).toEqual(56273823);
    expect(decoded.liquidity).toEqual(13122760518);
    expect(decoded.tickLower).toEqual(-66300);
    expect(decoded.tickUpper).toEqual(-60720);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_ROUTER_POOL_FUND_ACCOUNT_TX={} LT={}",
        TONCO_ROUTER_FUND_TX,
        TONCO_ROUTER_FUND_LT,
    );
}
