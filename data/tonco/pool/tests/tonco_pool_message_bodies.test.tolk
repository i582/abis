import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonco_pool.types"

const TONCO_POOL_SWAP_OWNER = "0:EF81C7A51E068EE150EA0EC970CD2A38FCDA77C1F92E7838D43404D66E82EDD7"
const TONCO_POOL_SWAP_SOURCE_WALLET = "0:85E822DFDF7BE8244274E2399BDD95E510E86D7E35D1A054D2A0A9938AC816A0"
const TONCO_POOL_MINT_OWNER = "0:2402798494478559E0025017E68B6ABEA90B1E034D2C0489EB8A108016641B91"
const TONCO_POOL_PAY_TO_TOKEN_1 = "0:871DA9215B14902166F0EA2A16DB56278D528108377F8158C5F4CCFDFDD22E17"

get fun `test tonco pool decodes mainnet swap body`() {
    val txHash = "jX8E7s98N/6Ai2GUGtW2wDfpVEQSUub72c6sPExzCB0=";
    val txLt = "58310381000001";
    val bodyBoc = "te6cckEBAwEAmQACnaf7WPgAAAAAAAAAAIAd8Dj0o8DR3CodQdkuGaVHH5tO+D8lzwcahoCazdBduvACF6CLf33voJEJ04jmb3ZXlEOhtfjXRoFTSoKmTisgWoIBAgA+YXt+GWMO4AAAAAAAAAAAAAAAAAAAABAAJ2pEGknUkQBFgB3wOPSjwNHcKh1B2S4ZpUcfm074PyXPBxqGgJrN0F264ARjtzqn";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Swap.fromCell(body);
    val params = decoded.paramsCell.load();
    val payloads = decoded.payloadsCell.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.ownerAddress).toEqual(address(TONCO_POOL_SWAP_OWNER));
    expect(decoded.sourceWallet).toEqual(address(TONCO_POOL_SWAP_SOURCE_WALLET));
    expect(params.amount).toEqual(26078531170542);
    expect(params.sqrtPriceLimitX96).toEqual(4295128740);
    expect(params.minOutAmount).toEqual(441046161);
    expect(payloads.targetAddress).toEqual(address(TONCO_POOL_SWAP_OWNER));
    expect(payloads.okForwardAmount).toEqual(0);
    expect(payloads.okForwardPayload).toBeNull();
    expect(payloads.retForwardAmount).toEqual(0);
    expect(payloads.retForwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_SWAP_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool decodes mainnet fund account body`() {
    val txHash = "Rkx+fj1IW2nQD4I7c403Uiv5JWNGk8mxwhqGbfZqI6s=";
    val txLt = "55638777000001";
    val bodyBoc = "te6cckEBAQEAWAAAq0Ro3ncAAAAAAAAAAIAEgE8wkojwqzwASgL80W1X1SFjwGmlgJE9cUIQAsyDcjACxorwuxP/uhACxorwuxP/ugAAAAAAAAAAAAAxAUreQ5D/yscAA2sQ8+u3hA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3FundAccount.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.ownerAddr).toEqual(address(TONCO_POOL_MINT_OWNER));
    expect(decoded.amount0).toEqual(99999999999999965);
    expect(decoded.amount1).toEqual(0);
    expect(decoded.enough0).toEqual(99999999999999965);
    expect(decoded.enough1).toEqual(0);
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FUND_ACCOUNT_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool decodes mainnet mint body`() {
    val txHash = "9u3P8+gp1OAa4AYb0m1zuqBRsNIXo3La13qzvQXFwec=";
    val txLt = "55638785000001";
    val bodyBoc = "te6cckEBAQEATwAAmYFwLvgAAAAAAAAAAIAWNFeF2J/90IAEgE8wkojwqzwASgL80W1X1SFjwGmlgJE9cUIQAsyDciAAAAAAAAAAAAAxAUreQ5D/yscAA2sQjEGUCw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Mint.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount0Funded).toEqual(99999999999999965);
    expect(decoded.amount1Funded).toEqual(0);
    expect(decoded.recipient).toEqual(address(TONCO_POOL_MINT_OWNER));
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool decodes mainnet router pay to body and nested payload`() {
    val txHash = "jX8E7s98N/6Ai2GUGtW2wDfpVEQSUub72c6sPExzCB0=";
    val txLt = "58310381000001";
    val bodyBoc = "te6cckECBAEAARcAArah2qltAAAAAAAAAACAHfA49KPA0dwqHUHZLhmlRx+bTvg/Jc8HGoaAms3QXbrwA74HHpR4GjuFQ6g7JcM0qOPzad8H5Lng41DQE1m6C7dcAAADIAAAAAAAAAA3AQIBjwgBC9BFv7730EiE6cRzN7sryiHQ2vxro0CppUFTJxWQLUCDprLbUAIcdqSFbFJAhZvDqKhbbVieNUoEIN3+BWMX0zP390i4XgMAzgAAAAAAAAAAAAGIQOp9b3MAAAAAAAAAAAEdfG5iWK9vM/sm0/5XRwAAAAAAAAAAAAAAAAAAAAAATnXc3c2vcGb/XIOq5GorAAAAAAAAAAAAAAAAAAAAAAAADhytSRBv6FtZbNFE0d4AAwAgoXyJBQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Routerv3PayTo.fromCell(body);
    val payTo = decoded.payTo;

    expect(decoded.queryId).toEqual(0);
    expect(decoded.receiver0).toEqual(address(TONCO_POOL_SWAP_OWNER));
    expect(decoded.receiver1).toEqual(address(TONCO_POOL_SWAP_OWNER));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    match (payTo) {
        PayToCode0 => {
            expect(false).toBeTrue();
        }
        PayToCode200 => {
            expect(payTo.seqno).toEqual(13);
            expect(payTo.coinsinfoCell).toBeNotNull();
            expect(payTo.indexerSwapInfoCell).toBeNotNull();
            val coinsinfo = payTo.coinsinfoCell!.load();
            val payload = coinsinfo.payloadCell.load();
            val indexer = payTo.indexerSwapInfoCell!.load();

            expect(coinsinfo.amount0).toEqual(0);
            expect(coinsinfo.jetton0Address).toEqual(address(TONCO_POOL_SWAP_SOURCE_WALLET));
            expect(coinsinfo.amount1).toEqual(490051290);
            expect(coinsinfo.jetton1Address).toEqual(address(TONCO_POOL_PAY_TO_TOKEN_1));
            expect(payload.payloadAmount0).toEqual(0);
            expect(payload.payloadCell0).toBeNull();
            expect(payload.payloadAmount1).toEqual(0);
            expect(payload.payloadCell1).toBeNull();
            expect(indexer.liquidity).toEqual(431287370084211);
            expect(indexer.priceSqrt).toEqual(345131468262500164664239827);
            expect(indexer.tick).toEqual(-108729);
            expect(indexer.feeGrowthGlobal0X128).toEqual(407389695729942389749101165629696555);
            expect(indexer.feeGrowthGlobal1X128).toEqual(286225752237428907345159555174878);
        }
        PayToCode201 => {
            expect(false).toBeTrue();
        }
        PayToCode230 => {
            expect(false).toBeTrue();
        }
    }

    println("TONCO_POOL_PAY_TO_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool decodes mainnet account add liquidity body`() {
    val txHash = "Rkx+fj1IW2nQD4I7c403Uiv5JWNGk8mxwhqGbfZqI6s=";
    val txLt = "55638777000001";
    val bodyBoc = "te6cckEBAQEANgAAaD6+VDEAAAAAAAAAAIAWNFeF2J/90IAWNFeF2J/90AAAAAAAAAAAAAGIClbyHIf+VjgAG1iFj5Cp";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Accountv3AddLiquidity.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newAmount0).toEqual(99999999999999965);
    expect(decoded.newAmount1).toEqual(0);
    expect(decoded.newEnough0).toEqual(99999999999999965);
    expect(decoded.newEnough1).toEqual(0);
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_ACCOUNT_ADD_LIQUIDITY_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool decodes mainnet position init body`() {
    val txHash = "9u3P8+gp1OAa4AYb0m1zuqBRsNIXo3La13qzvQXFwec=";
    val txLt = "55638785000001";
    val bodyBoc = "te6cckEBAgEApQABl9XsyioAAAAAAAAAAIAEgE8wkojwqzwASgL80W1X1SFjwGmlgJE9cUIQAsyDciAAAAAAAAAAAAAxAUreQ5D/yscAA2sAAAAAAAAAAHABAKgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAFjRXhdif/dD+VaXEaoXg";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = PositionnftV3PositionInit.fromCell(body);
    val oldFee = decoded.oldFeeCell.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.userAddress).toEqual(address(TONCO_POOL_MINT_OWNER));
    expect(decoded.liquidity).toEqual(431052966468743);
    expect(decoded.tickLower).toEqual(-109000);
    expect(decoded.tickUpper).toEqual(7000);
    expect(decoded.poolSeqno).toEqual(3);
    expect(oldFee.feeGrowthInside0LastX128).toEqual(0);
    expect(oldFee.feeGrowthInside1LastX128).toEqual(0);
    expect(oldFee.nftIndex).toEqual(1);
    expect(oldFee.jetton0Amount).toEqual(99999999999999965);
    expect(oldFee.jetton1Amount).toEqual(0);
    expect(oldFee.tick).toEqual(-109147);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_POSITION_INIT_TX={} LT={}", txHash, txLt);
}
