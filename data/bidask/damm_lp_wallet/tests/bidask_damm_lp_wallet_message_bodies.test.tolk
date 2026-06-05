import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_damm_lp_wallet.types"

const HISTORICAL_OWNER_ADDRESS = "0:10761F8FD0EF962DADAE290A4A75425947C2C44CFF466D9AA174E1C2A950424D"
const HISTORICAL_POOL_ADDRESS = "0:EA4D5179EEA4574301E70F9663F9F335232E3457CBF60D6AD5DD34354913F798"
const HISTORICAL_JETTON_WALLET_ADDRESS = "0:E452CC810BEB0608A4A1D7C46009C27AB962793C01B443D6A7EFE447C6A00FDF"

fun emptyInlineForwardPayload(): RemainingBitsAndRefs {
    return beginCell()
        .storeBool(false)
        .endCell()
        .beginParse();
}

fun expectNoTail(mutate tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectInlineEmptyForwardPayload(mutate payload: RemainingBitsAndRefs): void {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(0);
    expect(payload.loadBool()).toBeFalse();
    expectNoTail(mutate payload);
}

fun expectRefForwardPayload(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();

    val ref = payload.loadRef();
    expectNoTail(mutate payload);
    return ref;
}

fun zeroTransferFees(): BidaskDammLpWalletTransferFees {
    return {
        feesPerLpXLast: 0,
        feesPerLpYLast: 0,
    };
}

fun zeroBurnFees(): BidaskDammLpWalletBurnFees {
    return {
        feesPerLpXLast: 0,
        feesPerLpYLast: 0,
        claimedX: 0,
        claimedY: 0,
    };
}

fun zeroClaimFees(): BidaskDammLpWalletClaimFees {
    return {
        feesPerLpXLast: 0,
        feesPerLpYLast: 0,
        claimedX: 0,
        claimedY: 0,
    };
}

get fun `test bidask damm lp wallet decodes historical pool mint body`() {
    val txHash = "G/i/UmY0d7HQ4MziwUnVlk91Lw/GnNqELjnsPWQnBrY=";
    val txLt = "63363640000007";
    val bodyBoc = "te6cckEBAgEAkQABqSeuTv8ADyPzf211E1B6FktYSAHUmqLz3UiuhgPOHyzH8+ZqRlxor5fsGtWrumhqkifvMQAEHYfj9Dvli2trikKSnVCWUfCxEz/Rm2aoXThwqlQQk1ABAG4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATdz9WA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BidaskDammLpWalletMint.fromCell(body);
    val fees = decoded.fees.load();

    expect(decoded.queryId).toEqual(4261653372564755);
    expect(decoded.mintAmount).toEqual(32772502916);
    expect(decoded.fromAddress).toEqual(address(HISTORICAL_POOL_ADDRESS));
    expect(decoded.responseAddress).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(fees.feesPerLpXLast).toEqual(0);
    expect(fees.feesPerLpYLast).toEqual(0);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BIDASK_DAMM_LP_WALLET_MINT_TX={} LT={}", txHash, txLt);
}

get fun `test bidask damm lp wallet decodes historical internal burn body`() {
    val txHash = "aAnuAkQsv1DjJO1iH/FKnC2nqhAoatvlpaezpQeG90k=";
    val txLt = "63750375000005";
    val bodyBoc = "te6cckEBAgEAyAABqa2460kAA1LXT9E9a4ACDsPx+h3yxbW1xSFJTqhLKPhYiZ/ozbNULpw4VSoISaoPQslrCIACDsPx+h3yxbW1xSFJTqhLKPhYiZ/ozbNULpw4VSoISaQBANwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIYkxhg=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BidaskDammLpWalletInternalBurn.fromCell(body);
    val fees = decoded.fees.load();

    expect(decoded.queryId).toEqual(935509640691051);
    expect(decoded.burner).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decoded.burnAmount).toEqual(32772502916);
    expect(decoded.isAccount).toBeFalse();
    expect(decoded.receiver).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(fees.feesPerLpXLast).toEqual(0);
    expect(fees.feesPerLpYLast).toEqual(0);
    expect(fees.claimedX).toEqual(0);
    expect(fees.claimedY).toEqual(0);
    expect(decoded.additionalData).toBeNull();
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BIDASK_DAMM_LP_WALLET_INTERNAL_BURN_TX={} LT={}", txHash, txLt);
}

get fun `test bidask damm lp wallet decodes historical standard transfer body`() {
    val txHash = "aAnuAkQsv1DjJO1iH/FKnC2nqhAoatvlpaezpQeG90k=";
    val txLt = "63750375000005";
    val bodyBoc = "te6cckEBAQEAWAAArA+KfqUAA1LXT9E9a2AQFkTC+3gAIOw/H6HfLFtbXFIUlOqEso+FiJn+jNs1QunDhVKghJsABB2H4/Q75Ytra4pCkp1QllHwsRM/0ZtmqF04cKpUEJNAA6BuqQ==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BidaskDammLpWalletTransfer.fromCell(body);
    var forwardPayload = decoded.forwardPayload;

    expect(decoded.queryId).toEqual(935509640691051);
    expect(decoded.jettonAmount).toEqual(1105489309623);
    expect(decoded.toOwnerAddress).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decoded.responseAddress).toBeNotNull();
    expect(decoded.responseAddress!).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(0);
    expectInlineEmptyForwardPayload(mutate forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BIDASK_DAMM_LP_WALLET_STANDARD_TRANSFER_BODY_TX={} LT={}", txHash, txLt);
}

get fun `test bidask damm lp wallet decodes historical transfer notification body`() {
    val txHash = "G/i/UmY0d7HQ4MziwUnVlk91Lw/GnNqELjnsPWQnBrY=";
    val txLt = "63363640000007";
    val bodyBoc = "te6cckEBAgEAZAABaHNi0JwADyPzf211E2AQFkTLN8gAIOw/H6HfLFtbXFIUlOqEso+FiJn+jNs1QunDhVKghJsBAFWokEE0QM062PgAIOw/H6HfLFtbXFIUlOqEso+FiJn+jNs1QunDhVKghJoghfX7dA==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = BidaskDammLpWalletTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val payload = expectRefForwardPayload(mutate forwardPayload);

    expect(decoded.queryId).toEqual(4261653372564755);
    expect(decoded.amount).toEqual(1105489343356);
    expect(decoded.sender).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(payload.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println("BIDASK_DAMM_LP_WALLET_TRANSFER_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test bidask damm lp wallet synthetic burn and claim request bodies roundtrip`() {
    val burn = BidaskDammLpWalletBurn {
        queryId: 1001,
        burnAmount: 777,
        isAccount: false,
        receiver: address(HISTORICAL_OWNER_ADDRESS),
        additionalData: null,
        forwardPayload: null,
    };
    val decodedBurn = BidaskDammLpWalletBurn.fromCell(burn.toCell());

    expect(decodedBurn.queryId).toEqual(1001);
    expect(decodedBurn.burnAmount).toEqual(777);
    expect(decodedBurn.isAccount).toBeFalse();
    expect(decodedBurn.receiver).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decodedBurn.additionalData).toBeNull();
    expect(decodedBurn.forwardPayload).toBeNull();
    expect(decodedBurn.toCell().hash()).toEqual(burn.toCell().hash());

    val claim = BidaskDammLpWalletClaimFeesRequest {
        queryId: 1002,
        isAccount: true,
        receiver: address(HISTORICAL_OWNER_ADDRESS),
        forwardPayload: createEmptyCell(),
    };
    val decodedClaim = BidaskDammLpWalletClaimFeesRequest.fromCell(claim.toCell());

    expect(decodedClaim.queryId).toEqual(1002);
    expect(decodedClaim.isAccount).toBeTrue();
    expect(decodedClaim.receiver).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decodedClaim.forwardPayload).toBeNotNull();
    expect(decodedClaim.forwardPayload!.hash()).toEqual(createEmptyCell().hash());
    expect(decodedClaim.toCell().hash()).toEqual(claim.toCell().hash());

    println("BIDASK_DAMM_LP_WALLET_SYNTHETIC_OWNER_REQUESTS=burn,claim_fees");
}

get fun `test bidask damm lp wallet synthetic internal transfer and claim bodies roundtrip`() {
    val internalTransfer = BidaskDammLpWalletInternalTransfer {
        queryId: 2001,
        jettonAmount: 12345,
        fromAddress: address(HISTORICAL_OWNER_ADDRESS),
        responseAddress: null,
        forwardTonAmount: 0,
        fees: zeroTransferFees().toCell(),
        forwardPayload: emptyInlineForwardPayload(),
    };
    val decodedTransfer = BidaskDammLpWalletInternalTransfer.fromCell(internalTransfer.toCell());
    var transferForwardPayload = decodedTransfer.forwardPayload;

    expect(decodedTransfer.queryId).toEqual(2001);
    expect(decodedTransfer.jettonAmount).toEqual(12345);
    expect(decodedTransfer.fromAddress).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decodedTransfer.responseAddress).toBeNull();
    expect(decodedTransfer.forwardTonAmount).toEqual(0);
    expect(decodedTransfer.fees.load().feesPerLpXLast).toEqual(0);
    expect(decodedTransfer.fees.load().feesPerLpYLast).toEqual(0);
    expectInlineEmptyForwardPayload(mutate transferForwardPayload);
    expect(decodedTransfer.toCell().hash()).toEqual(internalTransfer.toCell().hash());

    val internalClaim = BidaskDammLpWalletInternalClaim {
        queryId: 2002,
        owner: address(HISTORICAL_OWNER_ADDRESS),
        isAccount: false,
        receiver: address(HISTORICAL_OWNER_ADDRESS),
        walletBalance: 32772502916,
        fees: zeroClaimFees().toCell(),
        forwardPayload: null,
    };
    val decodedClaim = BidaskDammLpWalletInternalClaim.fromCell(internalClaim.toCell());
    val claimFees = decodedClaim.fees.load();

    expect(decodedClaim.queryId).toEqual(2002);
    expect(decodedClaim.owner).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decodedClaim.isAccount).toBeFalse();
    expect(decodedClaim.receiver).toEqual(address(HISTORICAL_OWNER_ADDRESS));
    expect(decodedClaim.walletBalance).toEqual(32772502916);
    expect(claimFees.claimedX).toEqual(0);
    expect(claimFees.claimedY).toEqual(0);
    expect(decodedClaim.forwardPayload).toBeNull();
    expect(decodedClaim.toCell().hash()).toEqual(internalClaim.toCell().hash());

    println("BIDASK_DAMM_LP_WALLET_SYNTHETIC_INTERNAL_MESSAGES=internal_transfer,internal_claim");
}

get fun `test bidask damm lp wallet synthetic excesses body roundtrip`() {
    val excesses = BidaskDammLpWalletExcesses {
        queryId: 3001,
    };
    val decoded = BidaskDammLpWalletExcesses.fromCell(excesses.toCell());

    expect(decoded.queryId).toEqual(3001);
    expect(decoded.toCell().hash()).toEqual(excesses.toCell().hash());
    expect(address(HISTORICAL_JETTON_WALLET_ADDRESS).getWorkchain()).toEqual(0);

    println("BIDASK_DAMM_LP_WALLET_SYNTHETIC_EXCESSES=covered");
}
