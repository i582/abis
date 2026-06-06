import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/hipo_treasury.types"

const OWNER_MINT = "EQBw5RcWKkYiqkWR0jhRDWr_W8yUbhz95eMuKmZYcjKYBbGz"
const OWNER_RESERVE = "EQBF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBL1o"
const OWNER_BURN = "EQCk_NSgb3MZTfS1XWqDzaJuugePMlDWi6G0KuEre41DjGVn"
const HIPO_PARENT = "EQDPdq8xjAhytYqfGSX8KcFWIReCufsB9Wdg0pLlYSO_h76w"
const BORROWER = "0:9C9B4CE7DE3773C2A5F905F6F72C90392F0D79E149E8886DF0AAA95BBE2B0FFF"

const REQUEST_LOAN_QUERY_ID = 1780744155
const PROXY_NEW_STAKE_QUERY_ID = 1780755345
const STAKE_AT = 1780764424
const MAX_FACTOR = 294912
const VALIDATOR_PUBKEY = 0xa41414a54e2d0bc722e7a2254a94fc18fa65483d4875e8ae7a804bf76a8fba8d
const ADNL_ADDR = 0x20791d63c50ed91d13e2b1f5d68589d5cc9a10b81ab775c3543bdfb9ac74f00c
const NEW_STAKE_PAYLOAD_HASH = 0x9e88fafaf053de30f1a4bff56614d6109c10ed56e9c0231973cff6279af8094d
const SIGNATURE_HASH = 0x4cfd3580406373dfd5b502d847b26dc0787a557e5d35cb5e97adaaf6358c7dd5

fun bits256FromUint(value: uint256): bits256 {
    var bits = beginCell().storeUint(value, 256).endCell().beginParse();
    return bits.loadBits(256) as bits256;
}

fun expectNewStakePayload(payload: HipoTreasuryNewStakeMsg): void {
    expect(payload.validatorPubkey).toEqual(bits256FromUint(VALIDATOR_PUBKEY));
    expect(payload.stakeAt).toEqual(STAKE_AT);
    expect(payload.maxFactor).toEqual(MAX_FACTOR);
    expect(payload.adnlAddr).toEqual(bits256FromUint(ADNL_ADDR));
    expect(payload.signature.hash()).toEqual(SIGNATURE_HASH);
}

get fun `test hipo treasury decodes real deposit body`() {
    val txHash = "GiwKlU7Kaatc1SfLRk1b4EVaKb/6XKTDtjicbpnLFsU=";
    val txLt = "81966341000003";
    val body = parseCellFromBase64("te6cckEBAQEAFgAAJz03YabJKcxKaLBVURS6Q7dAAEBI5LXVKQ==");
    val decoded = HipoTreasuryDepositCoins.fromCell(body);

    expect(decoded.queryId).toEqual(14495341495624684881);
    expect(decoded.owner).toBeNull();
    expect(decoded.coins).toEqual(200000000000);
    expect(decoded.ownershipAssignedAmount).toEqual(1);
    expect(decoded.referrer).toBeNull();

    println("HIPO_TREASURY_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real reserve tokens body`() {
    val txHash = "N7Q+s1Fo9LgCV1L8s3PPSh16nUo4fr8746tCdMcKU04=";
    val txLt = "81945671000001";
    val body = parseCellFromBase64("te6cckEBAQEANwAAaThqNYsgSoiEQ1NWwlBJOHKACACLpOTOQeibKJbSWoC4+1Ds3oR2u/p7YMHJ2IGy80/CCAIDLCWhzg==");
    val decoded = HipoTreasuryReserveTokens.fromCell(body);

    expect(decoded.queryId).toEqual(2326822259136878274);
    expect(decoded.tokens).toEqual(19654977536);
    expect(decoded.owner).toEqual(address(OWNER_RESERVE));
    expect(decoded.mode).toEqual(0);
    expect(decoded.ownershipAssignedAmount).toEqual(1);

    println("HIPO_TREASURY_RESERVE_TOKENS_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real mint bill body`() {
    val txHash = "N7Q+s1Fo9LgCV1L8s3PPSh16nUo4fr8746tCdMcKU04=";
    val txLt = "81945671000001";
    val body = parseCellFromBase64("te6cckEBAQEAWAAAq0steHEgSoiEQ1NWwlBJOHKADABF0nJnIPRNlEtpLUBcfah2b0I7Xf09sGDk7EDZeafhBIAZ7tXmMYEOVrFT4yS/hTgqxCLwVz9gPqzsGlJcrCR38OIDPXkg6A==");
    val decoded = HipoTreasuryMintBill.fromCell(body);

    expect(decoded.queryId).toEqual(2326822259136878274);
    expect(decoded.amount).toEqual(19654977536);
    expect(decoded.unstake).toBeTrue();
    expect(decoded.owner).toEqual(address(OWNER_RESERVE));
    expect(decoded.parent).toEqual(address(HIPO_PARENT));
    expect(decoded.ownershipAssignedAmount).toEqual(1);

    println("HIPO_TREASURY_MINT_BILL_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real proxy tokens minted body`() {
    val txHash = "GiwKlU7Kaatc1SfLRk1b4EVaKb/6XKTDtjicbpnLFsU=";
    val txLt = "81966341000003";
    val body = parseCellFromBase64("te6cckEBAQEAPwAAeVvldibJKcxKaLBVUVKZpBDpJS6Q7dAAgA4couLFSMRVSLI6RwohrV/reZKNw5+8vGXFTMsORlMAoAAAABCaRWDK");
    val decoded = HipoTreasuryProxyTokensMinted.fromCell(body);

    expect(decoded.queryId).toEqual(14495341495624684881);
    expect(decoded.tokens).toEqual(178681613970);
    expect(decoded.coins).toEqual(200000000000);
    expect(decoded.owner).toEqual(address(OWNER_MINT));
    expect(decoded.roundSince).toEqual(0);

    println("HIPO_TREASURY_PROXY_TOKENS_MINTED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real proxy tokens burned body`() {
    val txHash = "7ZHtN05X7zl41r4OXL/NvJD0m5tzkNrhk6ka2cireUk=";
    val txLt = "81914237000029";
    val body = parseCellFromBase64("te6cckEBAQEAOwAAcUR2/eC0cqIYtygRsFA5E2Z61QP+KtSIgBSfmpQN7mMpvparrVB5tE3XQPHmShrRdDaFXCVvcahxkJujuQA=");
    val decoded = HipoTreasuryProxyTokensBurned.fromCell(body);

    expect(decoded.queryId).toEqual(13002633301207814576);
    expect(decoded.tokens).toEqual(15321163693);
    expect(decoded.coins).toEqual(17149121672);
    expect(decoded.owner).toEqual(address(OWNER_BURN));

    println("HIPO_TREASURY_PROXY_TOKENS_BURNED_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real request loan body`() {
    val txHash = "pVvcffoNbjO+JBi8os/XONZTeHyttj/cNfn9eywWXw4=";
    val txLt = "81913914000001";
    val body = parseCellFromBase64("te6cckEBAwEArgABPDYzXakAAAAAaiP/22okTwhwJPK+saoABRKgXyAADwEBkKQUFKVOLQvHIueiJUqU/Bj6ZUg9SHXornqAS/dqj7qNaiRPCAAEgAAgeR1jxQ7ZHRPisfXWhYnVzJoQuBq3dcNUO9+5rHTwDAIAgAF5IFYQHLjTYt94Y+32Wv5uVJRLWOQ2Wo5T3k8KIzXh4+pckjbsgVfsy3tmlv9fRiM4uGV8gOIUt6eZUUpH5wOu8zcC");
    val decoded = HipoTreasuryRequestLoan.fromCell(body);

    expect(decoded.queryId).toEqual(REQUEST_LOAN_QUERY_ID);
    expect(decoded.roundSince).toEqual(STAKE_AT);
    expect(decoded.loanAmount).toEqual(650000000000000);
    expect(decoded.minPayment).toEqual(80000000000);
    expect(decoded.borrowerRewardShare).toEqual(15);
    expect(decoded.newStakeMsg.hash()).toEqual(NEW_STAKE_PAYLOAD_HASH);
    expectNewStakePayload(decoded.newStakeMsg.load());

    println("HIPO_TREASURY_REQUEST_LOAN_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real proxy new stake body`() {
    val txHash = "HiUUsnNRvE9c/YoBsdI8tspYP6SegN7dNfLmllm2HuM=";
    val txLt = "81941545000010";
    val body = parseCellFromBase64("te6cckEBAwEAnAABGAic1NAAAAAAaiQrkQEBkKQUFKVOLQvHIueiJUqU/Bj6ZUg9SHXornqAS/dqj7qNaiRPCAAEgAAgeR1jxQ7ZHRPisfXWhYnVzJoQuBq3dcNUO9+5rHTwDAIAgAF5IFYQHLjTYt94Y+32Wv5uVJRLWOQ2Wo5T3k8KIzXh4+pckjbsgVfsy3tmlv9fRiM4uGV8gOIUt6eZUUpH5wNrfYZa");
    val decoded = HipoTreasuryProxyNewStake.fromCell(body);

    expect(decoded.queryId).toEqual(PROXY_NEW_STAKE_QUERY_ID);
    expect(decoded.newStakeMsg.hash()).toEqual(NEW_STAKE_PAYLOAD_HASH);
    expectNewStakePayload(decoded.newStakeMsg.load());

    println("HIPO_TREASURY_PROXY_NEW_STAKE_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real recover stake result body`() {
    val txHash = "DHwxpScSkpNKjTSa+HijLQu7QMB/dvIM857b6Da++hA=";
    val txLt = "80405231000001";
    val body = parseCellFromBase64("te6cckEBAQEANAAAYw/KTIYAAAAAahrPa8AJybTOfeN3PCpfkF9vcskDkvDXnhSeiIbfCqqVu+Kw//ahlPCIVjqApw==");
    val decoded = HipoTreasuryRecoverStakeResult.fromCell(body);

    expect(decoded.queryId).toEqual(1780141931);
    expect(decoded.ok).toBeTrue();
    expect(decoded.borrower).toEqual(address(BORROWER));
    expect(decoded.roundSince).toEqual(1780043528);

    println("HIPO_TREASURY_RECOVER_STAKE_RESULT_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real burn all body`() {
    val txHash = "DHwxpScSkpNKjTSa+HijLQu7QMB/dvIM857b6Da++hA=";
    val txLt = "80405231000001";
    val body = parseCellFromBase64("te6cckEBAQEAFgAAKGOdQAoAAAAAahrPawAAAAAAAAAAYu/lfQ==");
    val decoded = HipoTreasuryBurnAll.fromCell(body);

    expect(decoded.queryId).toEqual(1780141931);
    expect(decoded.startIndex).toEqual(0);

    println("HIPO_TREASURY_BURN_ALL_TX={} LT={}", txHash, txLt);
}

get fun `test hipo treasury decodes real gas excess body`() {
    val txHash = "5Bejzdam8juI9pLhjHf0Tl14zGtyMisjODUUnQmFSe8=";
    val txLt = "81899557000022";
    val body = parseCellFromBase64("te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=");
    val decoded = HipoTreasuryGasExcess.fromCell(body);

    expect(decoded.queryId).toEqual(0);

    println("HIPO_TREASURY_GAS_EXCESS_TX={} LT={}", txHash, txLt);
}
