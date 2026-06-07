import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/subscription_v2.types"

const SUBSCRIPTION_DEPLOY_WITHDRAW_ADDRESS = "0:B16A061860C9F389D4EF41FDFDAA7914BC09167DB9F5377B5EA95C504ED76B77"
const SUBSCRIPTION_DEPLOY_METADATA_BOC =
    "te6ccgEBAwEA+QABSAGORgtdy6ye9GXg83NoSCJMVlbX3BpxW32t1B3sMWxqcGNAegEB/utuT1lZuDtEThSxHSfugIMqwEnJeIi9Ex4JlLj0L4TyaIpMK+f7TV452zmy0/PNkmyU8Z8mGrtOpBpJa8j22GMQQf6J/YZrspmO30xOeHdCJ5MmEZPNkRof8KGJ4nVkaeruaPQKVXZnuulRGoFF8B7Af2w8B0H50cIVcKF96E0CAJxqp6B2Zwl7tAg+1xG0VTzzXBjnSvkQHWFVJN1uohm+lkq/3aeZOF3lGM85iO3FOjxAYhiDkud3afiM5Jls3v4ouGyr+usp0tr0og16H7Q="

fun expectEmptyCell(value: cell): void {
    val parsed = value.beginParse();
    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);
}

get fun `test subscription v2 decodes real deploy body`() {
    val txHash = "HwUINhGYmT9fD+QSQ8tCZmvlowIap4DEw8Z382AHYmo=";
    val txLt = "81984668000005";
    val bodyBoc = "te6cckECBQEAAT8AAn/3F4PLVG3k79s5itcAAAAAUBoKLvgAAnjQAAA/SACAFi1AwwwZPnE6neg/v7VPIpeBIs+3Pqbva9Urigna7W7wAQIAAAFIAY5GC13LrJ70ZeDzc2hIIkxWVtfcGnFbfa3UHewxbGpwY0B6AwH+625PWVm4O0ROFLEdJ+6AgyrAScl4iL0THgmUuPQvhPJoikwr5/tNXjnbObLT882SbJTxnyYau06kGklryPbYYxBB/on9hmuymY7fTE54d0InkyYRk82RGh/woYnidWRp6u5o9ApVdme66VEagUXwHsB/bDwHQfnRwhVwoX3oTQQAnGqnoHZnCXu0CD7XEbRVPPNcGOdK+RAdYVUk3W6iGb6WSr/dp5k4XeUYzzmI7cU6PEBiGIOS53dp+IzkmWze/ii4bKv66ynS2vSiDXoftNyzyAc=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = SubscriptionV2Deploy.fromCell(body);

    expect(decoded.queryId).toEqual(6083770390473706199);
    expect(decoded.firstChargeDate).toEqual(0);
    expect(decoded.paymentPerPeriod).toEqual(6990000000);
    expect(decoded.period).toEqual(2592000);
    expect(decoded.gracePeriod).toEqual(259200);
    expect(decoded.callerFee).toEqual(0);
    expect(decoded.withdrawAddress).toEqual(address(SUBSCRIPTION_DEPLOY_WITHDRAW_ADDRESS));
    expectEmptyCell(decoded.withdrawMsgBody);
    expect(decoded.metadata.hash()).toEqual(parseCellFromBase64(SUBSCRIPTION_DEPLOY_METADATA_BOC).hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("SUBSCRIPTION_V2_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test subscription v2 decodes real empty forwarded body`() {
    val txHash = "HwUINhGYmT9fD+QSQ8tCZmvlowIap4DEw8Z382AHYmo=";
    val txLt = "81984668000005";
    val bodyBoc = "te6cckEBAQEAAgAAAEysuc0=";
    val body = parseCellFromBase64(bodyBoc);

    expectEmptyCell(body);

    println("SUBSCRIPTION_V2_EMPTY_OUT_TX={} LT={}", txHash, txLt);
}
