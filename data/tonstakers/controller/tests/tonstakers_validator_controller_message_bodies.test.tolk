import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonstakers_validator_controller.types"

const MESSAGE_FIXTURE_JSON = "data/tonstakers/research/controller_recent_message_bodies.json"

const EXPECTED_VALIDATOR_ADDRESS = "-1:7C97DDA0CDA186AC54C4A6320DAB8E45F011B672655A473371BAF987D6BB5091"
const EXPECTED_POOL_ADDRESS = "0:A45B17F28409229B78360E3290420F13E4FE20F90D7E2BF8C4AC6703259E22FA"
const EXPECTED_GOVERNOR_ADDRESS = "0:8926460471725404B334847B35E4DCE1FE117ED048BE3CC627C57F8AFD28C44C"
const EXPECTED_APPROVER_ADDRESS = "0:C14641C95C49BE91E53C684346505A00842BCA24595DAB0B69B0CD84C12959E8"
const EXPECTED_HALTER_ADDRESS = "0:B3A2EC248B08BBBEC76D5DFC9AD69FF19D1C025956BE275ACEEDB047B1E175F7"

const EXPECTED_LOAN_QUERY_ID = 1731646226
const EXPECTED_MIN_LOAN = 499000000000000
const EXPECTED_MAX_LOAN = 901000000000000
const EXPECTED_MAX_INTEREST = 5033
const DOCUMENTED_NEW_STAKE_BODY_HASH = 0x35498cab5b7f4af4b272f0dc077aae2b5480497261ac98ba78a3e18b9ccfb4e0
const DOCUMENTED_NEW_STAKE_SIGNATURE_HASH = 0x8471aa3c8468af8d42aa223ab488c0ca37fd9a91125a0820a13cf978da6703ff

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

fun expectStaticControllerData(data: TonstakersValidatorControllerStaticData): void {
    val roles = data.roles.load();

    expect(data.controllerId).toEqual(0);
    expect(data.validator).toEqual(address(EXPECTED_VALIDATOR_ADDRESS));
    expect(data.pool).toEqual(address(EXPECTED_POOL_ADDRESS));
    expect(data.governor).toEqual(address(EXPECTED_GOVERNOR_ADDRESS));
    expect(roles.approver).toEqual(address(EXPECTED_APPROVER_ADDRESS));
    expect(roles.halter).toEqual(address(EXPECTED_HALTER_ADDRESS));
}

get fun `test tonstakers controller decodes real withdraw and validator withdrawal bodies`() {
    val txHash = "b4C6gJMwgkGw42WADqxC7rLzccAy2xgks/CyX1godTY=";
    val txLt = "50920164000003";
    val withdrawBodyBoc = "te6cckEBAQEAFQAAJY7+13kAAAAAZzdVemAYUPXIYAgno/v1";
    val validatorWithdrawalBodyBoc = "te6cckEBAQEADgAAGDACYycAAAAAZzdVeplRtL0=";

    val withdraw = TonstakersValidatorControllerWithdrawValidator.fromCell(
        parseCellFromBase64(withdrawBodyBoc),
    );
    val validatorWithdrawal = TonstakersValidatorControllerValidatorWithdrawal.fromCell(
        parseCellFromBase64(validatorWithdrawalBodyBoc),
    );

    expect(withdraw.queryId).toEqual(1731679610);
    expect(withdraw.requestAmount).toEqual(1671000000000);
    expect(validatorWithdrawal.queryId).toEqual(1731679610);

    println(
        "TONSTAKERS_CONTROLLER_WITHDRAW_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes real unused loan repayment and empty body`() {
    val txHash = "yI298AzXiMMxpTujXNwNBhUWh0Z6zib2VRn5bn7uhHc=";
    val txLt = "50919600000003";
    val returnUnusedBodyBoc = "te6cckEBAQEADgAAGO1zeKYAAAAAAAAAABV+9Lc=";
    val repaymentBodyBoc = "te6cckEBAQEADgAAGN/consAAAAAAAAAAOrQUms=";
    val emptyBodyBoc = "te6cckEBAQEAAgAAAEysuc0=";

    val returnUnused = TonstakersValidatorControllerReturnUnusedLoan.fromCell(
        parseCellFromBase64(returnUnusedBodyBoc),
    );
    val repayment = TonstakersValidatorControllerPoolLoanRepayment.fromCell(
        parseCellFromBase64(repaymentBodyBoc),
    );
    val emptyBody = parseCellFromBase64(emptyBodyBoc).beginParse();

    expect(returnUnused.queryId).toEqual(0);
    expect(repayment.queryId).toEqual(0);
    expect(emptyBody.remainingBitsCount()).toEqual(0);
    expect(emptyBody.remainingRefsCount()).toEqual(0);

    println(
        "TONSTAKERS_CONTROLLER_RETURN_UNUSED_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes real bounced return unused loan body`() {
    val txHash = "IwrMAPOOqV5ii58h6lQRjTLQYormIScnBlMhoUZWo/U=";
    val txLt = "50919599000001";
    val bouncedBodyBoc = "te6cckEBAQEAEgAAIP/////tc3imAAAAAAAAAAAqwhKp";
    val bounced = TonstakersValidatorControllerBouncedKnownBody.fromCell(
        parseCellFromBase64(bouncedBodyBoc),
    );
    val tail = bounced.tail;

    expect(bounced.originalOpcode).toEqual(0xed7378a6);
    expect(bounced.queryId).toEqual(0);
    expectNoTail(tail);

    println(
        "TONSTAKERS_CONTROLLER_BOUNCE_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes real pool credit body`() {
    val txHash = "OhvAQ9sIViwaedGRL/eqn8JN7MMHgLByb6qYjMOdRq8=";
    val txLt = "50908010000001";
    val creditBodyBoc = "te6cckEBAQEAFgAAJxaQxgQAAAAAZzbTEnAzOaO/PcC4wKP1DA==";
    val credit = TonstakersValidatorControllerCredit.fromCell(parseCellFromBase64(creditBodyBoc));

    expect(credit.queryId).toEqual(EXPECTED_LOAN_QUERY_ID);
    expect(credit.creditAmount).toEqual(901162453949451);

    println(
        "TONSTAKERS_CONTROLLER_CREDIT_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes real request loan in and out bodies`() {
    val txHash = "jC2NbxlnKQuS2/s0KSViG807ax4fDGQXDHjr0ICxh3Q=";
    val txLt = "50908007000003";
    val requestBodyBoc = "te6cckEBAQEAIAAAPGM1sRoAAAAAZzbTEnAcXWfb4wAHAzN0aPFQAAATqXyz0GU=";
    val poolRequestBodyBoc = "te6cckEBAwEA0gABPOZCyWUAAAAAZzbTEnAcXWfb4wAHAzN0aPFQAAATqQEB0QAAAACf75L7tBm0MNWKmJTGQbVxyL4CNs5Mq0jmbjdfMPrXahIwApFsX8oQJIpt4Ng4ykEIPE+T+IPkNfiv4xKxnAyWeIvqAESTIwI4uSoCWZpCPZrybnD/CL9oJF8eYxPiv8V+lGImQAIAhYAYKMg5K4k30jynjQhoygtAEIV5RIsrtWFtNhmwmCUrPRACzouwkiwi7vsdtXfya1p/xnRwCWVa+J1rO7bBHseF194GkXsL";

    val request = TonstakersValidatorControllerSendRequestLoan.fromCell(
        parseCellFromBase64(requestBodyBoc),
    );
    val poolRequest = TonstakersValidatorControllerPoolRequestLoan.fromCell(
        parseCellFromBase64(poolRequestBodyBoc),
    );
    val controllerData = poolRequest.controllerData.load();

    expect(request.queryId).toEqual(EXPECTED_LOAN_QUERY_ID);
    expect(request.minLoan).toEqual(EXPECTED_MIN_LOAN);
    expect(request.maxLoan).toEqual(EXPECTED_MAX_LOAN);
    expect(request.maxInterest).toEqual(EXPECTED_MAX_INTEREST);

    expect(poolRequest.queryId).toEqual(EXPECTED_LOAN_QUERY_ID);
    expect(poolRequest.minLoan).toEqual(EXPECTED_MIN_LOAN);
    expect(poolRequest.maxLoan).toEqual(EXPECTED_MAX_LOAN);
    expect(poolRequest.maxInterest).toEqual(EXPECTED_MAX_INTEREST);
    expectStaticControllerData(controllerData);

    println(
        "TONSTAKERS_CONTROLLER_REQUEST_LOAN_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes real elector recover ok and repayment bodies`() {
    val txHash = "W9VipPoYlPAmjYyHBghV33uxTG2Onkck8udnWkiHHTQ=";
    val txLt = "50907778000007";
    val recoverOkBodyBoc = "te6cckEBAQEADgAAGPlvcyQAAAAAAAAAAB/Snpk=";
    val repaymentBodyBoc = "te6cckEBAQEADgAAGN/consAAAAAAAAAAOrQUms=";

    val recoverOk = TonstakersValidatorControllerRecoverStakeOk.fromCell(
        parseCellFromBase64(recoverOkBodyBoc),
    );
    val repayment = TonstakersValidatorControllerPoolLoanRepayment.fromCell(
        parseCellFromBase64(repaymentBodyBoc),
    );

    expect(recoverOk.queryId).toEqual(0);
    expect(repayment.queryId).toEqual(0);

    println(
        "TONSTAKERS_CONTROLLER_RECOVER_OK_FIXTURE={} TX={} LT={}",
        MESSAGE_FIXTURE_JSON,
        txHash,
        txLt,
    );
}

get fun `test tonstakers controller decodes e0505d0e new stake layout`() {
    // No 0xe0505d0e body was present in the latest-50M mainnet snapshot.
    // This fixed BoC is an independently encoded conformance vector for the
    // exact upstream interaction.tlb layout, not a claimed mainnet message.
    val bodyBoc = "te6cckEBAgEAoAABteBQXQ4RIjNEVWZ3iGLXmIPSAAASNFZ4mrze8BI0VniavN7wEjRWeJq83vASNFZ4mrze9qGKUAAAEAAP7cuph2VDIQ/ty6mHZUMhD+3LqYdlQyEP7cuph2VDIQgBAIBaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlpa3aJ6vQ==";
    val body = parseCellFromBase64(bodyBoc);
    val message = TonstakersValidatorControllerNewStakeE0505d0e.fromCell(body);

    expect(body.hash()).toEqual(DOCUMENTED_NEW_STAKE_BODY_HASH);
    expect(message.queryId).toEqual(0x1122334455667788);
    expect(message.stakeValue).toEqual(50000000000000);
    expect(message.validatorPubkey).toEqual(
        0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef,
    );
    expect(message.stakeAt).toEqual(1780000000);
    expect(message.maxFactor).toEqual(65536);
    expect(message.adnlAddr).toEqual(
        0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210,
    );
    expect(message.signature.hash()).toEqual(DOCUMENTED_NEW_STAKE_SIGNATURE_HASH);
    expect(message.toCell().hash()).toEqual(body.hash());
}
