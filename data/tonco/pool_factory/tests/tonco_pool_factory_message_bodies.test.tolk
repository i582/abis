import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonco_pool_factory.types"

const TONCO_POOL_FACTORY_JETTON0_MINTER = "0:949c4c66760c002800e2fa3d8a3ca4e1c90a9373b53ae7472033483bf14cd95e"
const TONCO_POOL_FACTORY_JETTON1_MINTER = "0:4e38745d6950b0da7602b7f96bcf0a7f37288f7e1d3303642927ad7f78cbcb9d"
const TONCO_POOL_FACTORY_JETTON0_WALLET = "0:871da9215b14902166f0ea2a16db56278d528108377f8158c5f4ccfdfdd22e17"
const TONCO_POOL_FACTORY_JETTON1_WALLET = "0:3d9b013a4273639f5f788d4638a6135502011abe05398560170ee65b8d06d867"
const TONCO_POOL_FACTORY_ROUTER_ADDRESS = "0:bffadd270a738531da7b13ba8fc403826c2586173f9ede9c316fab53bc59ac86"
const TONCO_POOL_FACTORY_ADMIN_ADDRESS = "0:911177bf27ed7fcd01d143160acd1bbc31452506f7b893f4c57495449e12142d"
const TONCO_POOL_FACTORY_WHITELIST_ADDRESS = "0:7832aa3e3a01f26a16f47368862b9a2192122760d7ecdba8c4dfe95f73c1b077"

const TONCO_POOL_FACTORY_INITIAL_PRICE_X96 = 2079200043409542387916448664
const TONCO_POOL_FACTORY_SETTINGS = 2

const TONCO_POOL_FACTORY_CREATE_POOL_BODY_HASH = 0xa704384d39f9fca3f034dc3dc42b94c122f1dd6f1d3aafc545a02a6cfd711f64
const TONCO_POOL_FACTORY_ORDER_INIT_BODY_HASH = 0xc081c1ecb2497a5f839fdaf50ba3022fa94a3bcc23b92fcedec4984f95504ecd
const TONCO_POOL_FACTORY_ORDER_EXECUTE_BODY_HASH = 0x43e04800050f8175912b26d936394ee0b4013863d2c5ee4c29f9fe1d699dd1f0
const TONCO_POOL_FACTORY_ROUTER_CREATE_POOL_BODY_HASH = 0x9e3324f9f2536f4497e7d4a132f22d14fd2787e9d6e239c99fb97465f38bca1d
const TONCO_POOL_FACTORY_ROUTER_NFTV3_CONTENT_HASH = 0xfab70dcb23ec6283fa3897832829e42090a42a603f73fddd5715bce0483826e6
const TONCO_POOL_FACTORY_ROUTER_NFTV3ITEM_CONTENT_HASH = 0xf74ac4c9056959c2e7c9a47c7d545141f971d1f609c9658e54ccd9cdb01623ca
const TONCO_POOL_FACTORY_ADD_WHITELIST_BODY_HASH = 0x56e73b1fe0b8ee26725609d4d16013c754c4e54a84fa92290e2eab37febf5770

fun expectWalletPair(pair: ToncoPoolFactoryCreatePoolWalletCell): void {
    expect(pair.jetton0Wallet).toEqual(address(TONCO_POOL_FACTORY_JETTON0_WALLET));
    expect(pair.jetton1Wallet).toEqual(address(TONCO_POOL_FACTORY_JETTON1_WALLET));
}

fun expectMinterPair(pair: ToncoPoolFactoryOrderInitMinterCell): void {
    expect(pair.jetton0Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON0_MINTER));
    expect(pair.jetton1Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON1_MINTER));
}

get fun `test tonco pool factory decodes real create pool body`() {
    val txHash = "2o/AhBBxSgywOeVUtSRlvHuUByVnRSBFZHit7uzY7SQ=";
    val txLt = "81370102000012";
    val bodyBoc = "te6cckEBAgEArQAByZ6aj38AAAAAAAAAAIASk4mMzsGABQAcX0exR5ScOSFSbnanXOjkBmkHfimbK9ABOOHRdaVCw2nYCt/lrzwp/NyiPfh0zA2QpJ61/eMvLnQAAAAAAAAAABrffvDRvrTNSBaOYAAJAQCFgBDjtSQrYpIELN4dRULbasTxqlAhBu/wKxi+mZ+/ukXC8AD2bATpCc2OfX3iNRjimE1UCARq+BTmFYBcO5luNBthnmq4TM4=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPoolFactoryCreatePool.fromCell(body);

    expect(body.hash()).toEqual(TONCO_POOL_FACTORY_CREATE_POOL_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.jetton0Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON0_MINTER));
    expect(decoded.jetton1Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON1_MINTER));
    expect(decoded.initialPriceX96).toEqual(TONCO_POOL_FACTORY_INITIAL_PRICE_X96);
    expect(decoded.settings).toEqual(TONCO_POOL_FACTORY_SETTINGS);
    expectWalletPair(decoded.walletCell.load());
    expect(decoded.settingsCell).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FACTORY_CREATE_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool factory decodes real order init body`() {
    val txHash = "2o/AhBBxSgywOeVUtSRlvHuUByVnRSBFZHit7uzY7SQ=";
    val txLt = "81370102000012";
    val bodyBoc = "te6cckEBAgEAjAABh4uF3mMAAAAAAAAAAIAX/1uk4U5wpjtPYndR+IBwTYSwwufz29OGLfVqd4s1kMAAAAAAAAAAANb794aN9aZqQLRzAABQAQCFgBKTiYzOwYAFABxfR7FHlJw5IVJudqdc6OQGaQd+KZsr0AE44dF1pULDadgK3+WvPCn83KI9+HTMDZCknrX94y8uduUWoYM=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPoolFactoryOrderInit.fromCell(body);

    expect(body.hash()).toEqual(TONCO_POOL_FACTORY_ORDER_INIT_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.routerAddress).toEqual(address(TONCO_POOL_FACTORY_ROUTER_ADDRESS));
    expect(decoded.initialPriceX96).toEqual(TONCO_POOL_FACTORY_INITIAL_PRICE_X96);
    expect(decoded.settings).toEqual(TONCO_POOL_FACTORY_SETTINGS);
    expectMinterPair(decoded.minterCell.load());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FACTORY_ORDER_INIT_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool factory decodes real order execute body`() {
    val txHash = "zLaF3Jdm83Xh11DLiVRlYUOavkLucj03UCa+6UnesJM=";
    val txLt = "81370102000021";
    val bodyBoc = "te6cckEBAgEArQABydSzOwoAAAAAAAAAAIASk4mMzsGABQAcX0exR5ScOSFSbnanXOjkBmkHfimbK9ABOOHRdaVCw2nYCt/lrzwp/NyiPfh0zA2QpJ61/eMvLnQAAAAAAAAAABrffvDRvrTNSBaOYAAKAQCFgBDjtSQrYpIELN4dRULbasTxqlAhBu/wKxi+mZ+/ukXC8AD2bATpCc2OfX3iNRjimE1UCARq+BTmFYBcO5luNBthnlmpxRo=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPoolFactoryOrderExecute.fromCell(body);

    expect(body.hash()).toEqual(TONCO_POOL_FACTORY_ORDER_EXECUTE_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.jetton0Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON0_MINTER));
    expect(decoded.jetton1Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON1_MINTER));
    expect(decoded.initialPriceX96).toEqual(TONCO_POOL_FACTORY_INITIAL_PRICE_X96);
    expect(decoded.settings).toEqual(TONCO_POOL_FACTORY_SETTINGS);
    expectWalletPair(decoded.walletCell.load());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FACTORY_ORDER_EXECUTE_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool factory decodes real router create pool body`() {
    val txHash = "zLaF3Jdm83Xh11DLiVRlYUOavkLucj03UCa+6UnesJM=";
    val txLt = "81370102000021";
    val bodyBoc = "te6cckECGQEAA2UAA9cuMDTvAAAAAAAAAACAEOO1JCtikgQs3h1FQttqxPGqUCEG7/ArGL6Zn7+6RcLwAPZsBOkJzY59feI1GOKYTVQIBGr4FOYVgFw7mW40G2GcAADwAAAAAAAAAAAa337w0b60zUgWjmIPoAA8AD0BAgMBAwDABAEDAMAOAMmAEpOJjM7BgAUAHF9HsUeUnDkhUm52p1zo5AZpB34pmyvQATjh0XWlQsNp2Arf5a88Kfzcoj34dMwNkKSetf3jLy52AEiIu9+T9r/mgOihiwVmjd4YopKDe9xJ+mK6SqJPCQoWwAIBIAUGAgFYBwgCASAKCwFBv33xdLM40uUY0xqZuUQIHCQ1llVTbalFkV4FuhcicxnPCQFBv0ILrZjtXoAGS9KasRnKI3y3+3bnaG+4o9lIci+vSHx7EQBQAGh0dHBzOi8vdG9uY28uaW8vc3RhdGljL3RvbmNvLWNvdmVyLnBuZwFCv4KjU3/w285+7DXWntw6GJ7m8X2C81OlU/mqlssL486JDAFCv4kEb3o3rQ6nzuczVZhPpUKJgvizfI97zskfescafNEEDQAYAFBvb2wgTWludGVyAFIAVE9OQ08gUG9vbCBMUCBNaW50ZXIgZm9yIGEgc3BlY2lmaWMgcGFpcgIBIA8QAUO/8ILrZjtXoAGS9KasRnKI3y3+3bnaG+4o9lIci+vSHx7AEQIBIBITAFYAaHR0cHM6Ly90b25jby5pby9zdGF0aWMvdG9uY28tbG9nby1uZnQucG5nAUK/gqNTf/Dbzn7sNdae3DoYnubxfYLzU6VT+aqWywvjzokUAgEgFRYAHABQb29sIFBvc2l0aW9uAUO/Ugje9G9aHU+dzmarMJ9KhRMF8Wb5Hvedkj71jjT5oggBFwFBv2Nptm3yEcqvxGQi7W2mi+tOAan3UvJwLApk/7g5FbfvGADwACVOJQpKZXR0b24wOiBFUUNVbkV4bWRnd0FLQURpLWoyS1BLVGh5UXFUYzdVNjUwY2dNMGc3OFV6WlhuOUoKSmV0dG9uMTogRVFCT09IUmRhVkN3Mm5ZQ3RfbHJ6d3BfTnlpUGZoMHpBMlFwSjYxX2VNdkxuWjNoAE4AW3sidHJhaXRfdHlwZSI6IkRFWCIsInZhbHVlIjoiVE9OQ08ifV0831jU";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Routerv3CreatePool.fromCell(body);
    val minterCell = decoded.minterCell.load();

    expect(body.hash()).toEqual(TONCO_POOL_FACTORY_ROUTER_CREATE_POOL_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.jettonWallet0).toEqual(address(TONCO_POOL_FACTORY_JETTON0_WALLET));
    expect(decoded.jettonWallet1).toEqual(address(TONCO_POOL_FACTORY_JETTON1_WALLET));
    expect(decoded.tickSpacing).toEqual(60);
    expect(decoded.initialPriceX96).toEqual(TONCO_POOL_FACTORY_INITIAL_PRICE_X96);
    expect(decoded.activatePool).toBeTrue();
    expect(decoded.protocolFee).toEqual(2000);
    expect(decoded.lpFeeBase).toEqual(30);
    expect(decoded.lpFeeCurrent).toEqual(30);
    expect(decoded.nftv3Content.hash()).toEqual(TONCO_POOL_FACTORY_ROUTER_NFTV3_CONTENT_HASH);
    expect(decoded.nftv3itemContent.hash()).toEqual(
        TONCO_POOL_FACTORY_ROUTER_NFTV3ITEM_CONTENT_HASH,
    );
    expect(minterCell.jetton0Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON0_MINTER));
    expect(minterCell.jetton1Minter).toEqual(address(TONCO_POOL_FACTORY_JETTON1_MINTER));
    expect(minterCell.controllerAddress).toEqual(address(TONCO_POOL_FACTORY_ADMIN_ADDRESS));
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FACTORY_ROUTER_CREATE_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test tonco pool factory decodes real add whitelist body`() {
    val txHash = "Ht6E1vueA2wfgJJvPrNqprrAmNEFTRFjQPbbqqwpcLo=";
    val txLt = "78435216000023";
    val bodyBoc = "te6cckEBAQEAMAAAXI13IfAAAAAAAAAAAIAPBlVHx0A+TULejm0QxXNEMkJE7Br9m3UYm/0r7ng2Dv8BD+2K";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPoolFactoryAddToWhitelist.fromCell(body);

    expect(body.hash()).toEqual(TONCO_POOL_FACTORY_ADD_WHITELIST_BODY_HASH);
    expect(decoded.queryId).toEqual(0);
    expect(decoded.address).toEqual(address(TONCO_POOL_FACTORY_WHITELIST_ADDRESS));
    expect(decoded.allowSetController).toBeTrue();
    expect(decoded.allowSetCreator).toBeTrue();
    expect(decoded.allowSetActive).toBeTrue();
    expect(decoded.allowSetSettings).toBeTrue();
    expect(decoded.allowSetContent).toBeTrue();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("TONCO_POOL_FACTORY_ADD_WHITELIST_TX={} LT={}", txHash, txLt);
}
