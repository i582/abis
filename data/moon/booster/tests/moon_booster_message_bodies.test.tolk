import "@acton/fmt"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "../types/moon_booster.types"

const MOON_ADMIN = "0:C6D9A5D1BEEEEA7E567510AD309205CBD2241E26D850AA0448676A74D4BF2129"
const MOON_RESPONSE_DESTINATION = "0:7F80DF878A1172F5DA0859CEF8DB18FB907BDE5DBF1B3D916812E257DC86F2EE"
const MOON_POOL = "0:8CA560A70C756132752CA4068AC5A8245EE5B434684CABA63E1C25BF04EDB47B"
const MOON_ADMIN_USDT_WALLET = "0:FD617BDD3EDC260CAEE23396F69873DD297251C067DD3FA357532F7C3D79AB46"

fun expectNoTail(tail: RemainingBitsAndRefs): void {
    expect(tail.remainingBitsCount()).toEqual(0);
    expect(tail.remainingRefsCount()).toEqual(0);
}

get fun `test moon booster decodes real deployment configuration and funding request`() {
    val configureTxHash = "LzByukmVurGFWB26X2T+6tVEqamE0PRugx6zywLwHj0=";
    val configureTxLt = "56606560000001";
    val configureBody = parseCellFromBase64(
        "te6cckEBAgEATwABY5t38LIAAAAAAAVxDgKAH6wve6fbhMGV3EZy3tMOe6UuSjgM+6f0aupl74evNWjGmJaBAQAvMPQkAAAAAAaBEx/gAAAAAAAAABUYAABSXeOKuA==",
    );
    val configure = MoonBoosterConfigure.fromCell(configureBody);
    val boost = configure.boost.load();

    expect(configure.queryId).toEqual(356622);
    expect(configure.mode).toEqual(2);
    expect(boost.amountPerRound).toEqual(1000000);
    expect(boost.startTime).toEqual(1745957374);
    expect(boost.currentRound).toEqual(0);
    expect(boost.roundInterval).toEqual(86400);
    expect(boost.roundCount).toEqual(5);
    expect(boost.jettonWallet).toBeNull();
    match (configure.funding) {
        MoonBoosterFundingTail => {
            expect(configure.funding.fundingAddress).toBeNotNull();
            expect(configure.funding.fundingAddress!).toEqual(address(MOON_ADMIN_USDT_WALLET));
            expect(configure.funding.amount).toEqual(5000000);
        }
        void => {
            Assert.fail("Expected the deployment configuration to contain Jetton funding fields");
        }
    }
    expect(configure.toCell().hash()).toEqual(configureBody.hash());

    val requestBody = parseCellFromBase64(
        "te6cckEBAQEAfgAA97NkTwkAAAAAAAVxDgAAAAAAAAANgA/wG/DxQi5eu0ELOd8bYx9yD3vLt+Nnsi0CXEr7kN5d0AIylYKcMdWEydSykBorFqCRe5bQ0aEyrpj4cJb8E7bR7gB+sL3un24TBldxGct7TDnulLko4DPun9GrqZe+HrzVoxpiWgTJfuCa",
    );
    val request = MoonBoosterFundingRequest.fromCell(requestBody);

    expect(request.queryId).toEqual(configure.queryId);
    expect(request.boosterId).toEqual(13);
    expect(request.responseDestination).toBeNotNull();
    expect(request.responseDestination!).toEqual(address(MOON_RESPONSE_DESTINATION));
    expect(request.pool).toBeNotNull();
    expect(request.pool!).toEqual(address(MOON_POOL));
    expect(request.fundingAddress).toBeNotNull();
    expect(request.fundingAddress!).toEqual(address(MOON_ADMIN_USDT_WALLET));
    expect(request.amount).toEqual(5000000);
    expect(request.toCell().hash()).toEqual(requestBody.hash());
    println("MOON_BOOSTER_CONFIGURE_TX={} LT={}", configureTxHash, configureTxLt);
}

get fun `test moon booster decodes real Jetton funding notification`() {
    val txHash = "ivtYS6cu0sbi91DH9FcN6Ud6eINZOpAVGK4Q8NVaeyc=";
    val txLt = "56606568000001";
    val body = parseCellFromBase64(
        "te6cckEBAgEANgABYnNi0JwAAAAAAAVxDjTEtAgBjbNLo33d1Pys6iFaYSQLl6RIPE2woVQIkM7U6al+QlMBAAD0CuY3",
    );
    val notification = MoonBoosterJettonTransferNotification.fromCell(body);
    var forwardPayload = notification.forwardPayload;

    expect(notification.queryId).toEqual(356622);
    expect(notification.amount).toEqual(5000000);
    expect(notification.sender).toBeNotNull();
    expect(notification.sender!).toEqual(address(MOON_ADMIN));
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(1);
    expect(forwardPayload.loadBool()).toBeTrue();
    val payloadRef = forwardPayload.loadRef().beginParse();
    expect(payloadRef.remainingBitsCount()).toEqual(0);
    expect(payloadRef.remainingRefsCount()).toEqual(0);
    expectNoTail(forwardPayload);
    expect(notification.toCell().hash()).toEqual(body.hash());
    println("MOON_BOOSTER_JETTON_NOTIFY_TX={} LT={}", txHash, txLt);
}

get fun `test moon booster decodes real scheduled Jetton pool boost`() {
    val txHash = "QZkGkCChcvfRqdn0Ix052LZhFwPcJtVo/LZzQRIYKVU=";
    val txLt = "56717943000001";
    val body = parseCellFromBase64(
        "te6cckEBAgEAggABrg+KfqUAAAAAAAAAADD0JAgBGUrBThjqwmTqWUgNFYtQSL3LaGjQmVdMfDhLfgnbaPcAH+A34eKEXL12ghZzvjbGPuQe95dvxs9kWgS4lfchvLuIC+vCAQEAS5aqFYaAD/Ab8PFCLl67QQs53xtjH3IPe8u342eyLQJcSvuQ3l3Qly21Aw==",
    );
    val transfer = MoonBoosterJettonTransfer.fromCell(body);
    var forwardPayload = transfer.forwardPayload;

    expect(transfer.queryId).toEqual(0);
    expect(transfer.amount).toEqual(1000000);
    expect(transfer.destination).toBeNotNull();
    expect(transfer.destination!).toEqual(address(MOON_POOL));
    expect(transfer.responseDestination).toBeNotNull();
    expect(transfer.responseDestination!).toEqual(address(MOON_RESPONSE_DESTINATION));
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(100000000);
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(1);
    expect(forwardPayload.loadBool()).toBeTrue();
    val boostPayload = MoonBoosterJettonBoostPayload.fromCell(forwardPayload.loadRef());
    expectNoTail(forwardPayload);
    expect(boostPayload.responseDestination).toBeNotNull();
    expect(boostPayload.responseDestination!).toEqual(address(MOON_RESPONSE_DESTINATION));
    expect(transfer.toCell().hash()).toEqual(body.hash());
    println("MOON_BOOSTER_POOL_BOOST_TX={} LT={}", txHash, txLt);
}

get fun `test moon booster recognizes real empty tick-tock trigger body`() {
    val txHash = "09IjqGBFEPjGw5HP3Oq4nu9izrsHMfZrLtowCk/VXY0=";
    val txLt = "56718000000001";
    val body = parseCellFromBase64("te6cckEBAQEAAgAAAEysuc0=");
    val parsed = body.beginParse();

    expect(parsed.remainingBitsCount()).toEqual(0);
    expect(parsed.remainingRefsCount()).toEqual(0);
    println("MOON_BOOSTER_EMPTY_TRIGGER_TX={} LT={}", txHash, txLt);
}
