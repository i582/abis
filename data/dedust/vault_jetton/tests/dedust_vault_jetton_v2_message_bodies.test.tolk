import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/dedust_vault_jetton_v2.types"

const SWAP_QUERY_ID = 0xf4ce711700000000 as uint64
const PAYOUT_QUERY_ID = 146446
const SWAP_AMOUNT = 99500000
const PAYOUT_AMOUNT = 130662993
const SWAP_LIMIT = 55826895619
const PAYOUT_FORWARD_TON_AMOUNT = 247407257
const EXPECTED_VAULT_PROOF_HASH = 0x8930570816a375a5842b789274be53e37476a1bbcce751c1c0d8211f54951418

const SWAP_SENDER = "EQB6LiLct5nw3HiBU1WcjOUNdOcnl62QUyrNC394S2Pi7aSS"
const PAYOUT_RECIPIENT = "EQCM9RQP6iuZLTE0kYbz6Xk0jUsxKy4ehJhFNZdTJCQ_fCwW"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun loadDedustForwardPayloadRef(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val payloadCell = payload.loadRef();
    expectNoTail(mutate payload);
    return payloadCell;
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

get fun `test dedust jetton vault v2 decodes toncenter swap transfer notification body`() {
    val txHash = "Ij/BWEEls7TWGTFxcud2cvvnwXnAM4/wNThmgMzESuo=";
    val txLt = "81519975000007";
    val bodyBoc = "te6cckEBBAEAuQABZHNi0Jz0znEXAAAAAEBe4/4IAPRcRblvM+G48QKmqzkZyhrpzk8vWyCmVZoW/vCWx8XbAQJX46DUgoAHy/+VG7+ebYbZP+jeYqxVVqNzIpCLWthNl7zJOrFKsQUM/4rTA8ACAwBTgAxg/7Jlu0nQwx7ci/wMTGdPmN+Qtkb14/CAcQfgF1+nZwf065e96/9AAEtqIZpigA9FxFuW8z4bjxAqarORnKGunOTy9bIKZVmhb+8JbHxdoZTWyR4=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustVaultJettonV2TransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payloadCell = loadDedustForwardPayloadRef(mutate forwardPayload);
    val swapPayload = DedustVaultJettonV2SwapForwardPayload.fromCell(payloadCell);

    expect(decoded.queryId).toEqual(SWAP_QUERY_ID);
    expect(decoded.amount).toEqual(SWAP_AMOUNT);
    expect(decoded.sender).toEqual(address(SWAP_SENDER));
    expect(swapPayload.step.params.limit).toEqual(SWAP_LIMIT);
    expect(swapPayload.toCell().hash()).toEqual(payloadCell.hash());
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_JETTON_VAULT_V2_TONCENTER_SWAP_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test dedust jetton vault v2 decodes toncenter swap external body`() {
    val txHash = "Ij/BWEEls7TWGTFxcud2cvvnwXnAM4/wNThmgMzESuo=";
    val txLt = "81519975000007";
    val bodyBoc = "te6cckEBBAEA1wADb2HuVC30znEXAAAAAEBe4/4IAPRcRblvM+G48QKmqzkZyhrpzk8vWyCmVZoW/vCWx8XaUM/4rTA8AQIDAIeAC+Csn2vsCPB7auBjnDns0VEamprbTbybZEVpckGt+wAAIgFiJ1MpagSULOM+0icmUdbrKy2HFEvrIFFijf2bhsQ7/QBTgAxg/7Jlu0nQwx7ci/wMTGdPmN+Qtkb14/CAcQfgF1+nZwf065e96/9AAEtqIZpigA9FxFuW8z4bjxAqarORnKGunOTy9bIKZVmhb+8JbHxdoVKTXDw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustVaultJettonV2SwapExternal.fromCell(body);

    expect(decoded.queryId).toEqual(SWAP_QUERY_ID);
    expect(decoded.proof.hash()).toEqual(EXPECTED_VAULT_PROOF_HASH);
    expect(decoded.amount).toEqual(SWAP_AMOUNT);
    expect(decoded.senderAddr).toEqual(address(SWAP_SENDER));
    expect(decoded.current.limit).toEqual(SWAP_LIMIT);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_JETTON_VAULT_V2_TONCENTER_SWAP_EXTERNAL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust jetton vault v2 decodes toncenter pay out from pool body`() {
    val txHash = "8n33AxfawWwOj/b7Rbsooib7w7/7aBy/GDQsKYDuKhA=";
    val txLt = "81520194000008";
    val bodyBoc = "te6cckEBAgEAfAABZK1OtvUAAAAAAAI8DkB8nCUYARnqKB/UVzJaYmkjDefS8mkalmJWXD0JMIprLqZISH74AQCJgAvgrJ9r7Ajwe2rgY5w57NFRGpqa2028m2RFaXJBrfsAAEAQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id/o3vy6Sg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustVaultJettonV2PayOutFromPool.fromCell(body);

    expect(decoded.queryId).toEqual(PAYOUT_QUERY_ID);
    expect(decoded.amount).toEqual(PAYOUT_AMOUNT);
    expect(decoded.recipientAddr).toBeNotNull();
    expect(decoded.recipientAddr!).toEqual(address(PAYOUT_RECIPIENT));
    expect(decoded.payload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_JETTON_VAULT_V2_TONCENTER_PAY_OUT_FROM_POOL_TX={} LT={}", txHash, txLt);
}

get fun `test dedust jetton vault v2 decodes toncenter emitted jetton transfer body`() {
    val txHash = "8n33AxfawWwOj/b7Rbsooib7w7/7aBy/GDQsKYDuKhA=";
    val txLt = "81520194000008";
    val bodyBoc = "te6cckEBAQEAWgAAsA+KfqUAAAAAAAI8DkB8nCUYARnqKB/UVzJaYmkjDefS8mkalmJWXD0JMIprLqZISH75ACM9RQP6iuZLTE0kYbz6Xk0jUsxKy4ehJhFNZdTJCQ/fCB1+RTL5TEvi";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = DedustVaultJettonV2JettonTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(PAYOUT_QUERY_ID);
    expect(decoded.amount).toEqual(PAYOUT_AMOUNT);
    expect(decoded.destination).toBeNotNull();
    expect(decoded.destination!).toEqual(address(PAYOUT_RECIPIENT));
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(address(PAYOUT_RECIPIENT));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(PAYOUT_FORWARD_TON_AMOUNT);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("DEDUST_JETTON_VAULT_V2_TONCENTER_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}
