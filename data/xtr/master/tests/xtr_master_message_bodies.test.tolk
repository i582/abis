import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/xtr_master.types"

get fun `test xtr master decodes real signed purchase request`() {
    val txHash = "X6hC7v+cwomadT7YU1klcKwurXuUuyWh/PcvicUXV0w=";
    val txLt = "90785650000003";
    val bodyBoc = "te6cckEBAQEAdQAA5W/CVSCABZLz7Udl6FsuXzxztKM2Op62RvLxLCi1RS8az5saiV5KBWuYnAA9TU7KUw2NwEAnUUbb2bkbfKutUuiamHarbv/wvSECK4I9fvCxNpIrhKn0KjhilNe+wRwna3djc72ylfgKttAU1LTB6HycOBD4VRIG";
    val body = parseCellFromBase64(bodyBoc);
    val request = XtrMasterBuyXtr.fromCell(body);

    expect(request.userAddress).toEqual(
        address("EQAsl59qOy9C2XL5452lGbHU9bI3l4lhRaopeNZ82NRK8nlA"),
    );
    expect(request.amount).toEqual(11640000000);
    expect(request.starPrice.timestamp).toEqual(1784307956);
    expect(request.starPrice.starPrice).toEqual(15000000);
    expect(request.toCell().hash()).toEqual(body.hash());
    println(
        "XTR_BUY_TX={} LT={} AMOUNT={} VALID_UNTIL={} PRICE={}",
        txHash,
        txLt,
        request.amount,
        request.starPrice.timestamp,
        request.starPrice.starPrice,
    );
}

get fun `test xtr master decodes real payment and user routing bodies`() {
    val paymentTxHash = "c6UOJUeOVPmGhGcTtrVqS2nFyFzeTTmgeT+VCTBsaBM=";
    val paymentBody = parseCellFromBase64(
        "te6cckEBAgEALwABSyqZnfSACswTBAofVbs9OTIH5Go/5KVYh0TWABM39yJnzYz2IRbQAQAIRggQK7QqHR0=",
    );
    val payment = XtrMasterUpdatePayment.fromCell(paymentBody);
    val userTxHash = "Lq+e054/ju9g02FCg/4x/rcb52vlPGt7KBsNVJlTUHo=";
    val userBody = parseCellFromBase64(
        "te6cckEBAgEAXgABS1n/gdaACf3rp3gGi912K1tNZbeWpRl4Dpkmh06KKDGO7rtT0AnwAQBl5HKTXAAAAAAAAAASgAWS8+1HZehbLl88c7SjNjqetkby8SwotUUvGs+bGoleSgVrmJwBi2jUuA==",
    );
    val user = XtrMasterUpdateUser.fromCell(userBody);

    expect(payment.destination).toEqual(
        address("kQBWYJggUPqt2enJkD8jUf8lKsQ6JrAAmb-5Ez5sZ7EIth5a"),
    );
    expect(payment.payload.hash()).toEqual(
        29223019327518469926561433991726366562356547530449407419254742575692373592767,
    );
    expect(user.destination).toEqual(
        address("kQBP7107wDRe67Fa2mstvLUoy8B0yTQ6dFFBjHd12p6AT6jL"),
    );
    expect(user.payload.hash()).toEqual(
        62287073541142410569998983792761955777530826473819606237888191255188754356525,
    );
    expect(payment.toCell().hash()).toEqual(paymentBody.hash());
    expect(user.toCell().hash()).toEqual(userBody.hash());
    println(
        "XTR_PAYMENT_TX={} DESTINATION={} PAYLOAD_HASH={}",
        paymentTxHash,
        payment.destination,
        payment.payload.hash(),
    );
    println(
        "XTR_USER_TX={} DESTINATION={} PAYLOAD_HASH={}",
        userTxHash,
        user.destination,
        user.payload.hash(),
    );
}

get fun `test xtr master decodes real burn notification event and excess`() {
    val txHash = "MkiIex7orw3Ocbgh8INQI+Euv+KR6DE9QzxdXO7qa3A=";
    val txLt = "87343989000017";
    val burnBody = parseCellFromBase64(
        "te6cckEBAgEAaQABp3vdl94AAAAAAAAAAEO5rKAIAFkvPtR2XoWy5fPHO0ozY6nrZG8vEsKLVFLxrPmxqJXlAAsl59qOy9C2XL5452lGbHU9bI3l4lhRaopeNZ82NRK8sAEAIN4rUgSAOU8DpUkLOIz5tySefG7M",
    );
    val eventBody = parseCellFromBase64(
        "te6cckEBAgEAPwABVMpETOZDuaygCABZLz7Udl6FsuXzxztKM2Op62RvLxLCi1RS8az5saiV5QEAIN4rUgSAOU8DpUkLOIz5tyRf0ZGh",
    );
    val excessBody = parseCellFromBase64("te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=");
    val burn = XtrMasterBurnNotification.fromCell(burnBody);
    val event = XtrMasterBurnEvent.fromCell(eventBody);
    val excess = XtrMasterExcess.fromCell(excessBody);

    expect(burn.queryId).toEqual(0);
    expect(burn.amount).toEqual(1000000000);
    expect(burn.sender).toEqual(address("EQAsl59qOy9C2XL5452lGbHU9bI3l4lhRaopeNZ82NRK8nlA"));
    expect(burn.responseDestination).toBeNotNull();
    expect(burn.responseDestination!).toEqual(burn.sender);
    expect(event.amount).toEqual(burn.amount);
    expect(event.sender).toEqual(burn.sender);
    expect(excess.queryId).toEqual(burn.queryId);
    expect(burn.toCell().hash()).toEqual(burnBody.hash());
    expect(event.toCell().hash()).toEqual(eventBody.hash());
    expect(excess.toCell().hash()).toEqual(excessBody.hash());
    println("XTR_BURN_TX={} LT={}", txHash, txLt);
}

get fun `test xtr master decodes real child update and purchase dispatch`() {
    val updateTxHash = "c6UOJUeOVPmGhGcTtrVqS2nFyFzeTTmgeT+VCTBsaBM=";
    val updateBody = parseCellFromBase64(
        "te6cckECHgEABGcAAlPiYoU5gANmYr7mmyKoCTxG6xAYdidsisYdDQtOofT3YQmZWe+yKAmJaAEBAgIIAAAAAAMEAAhGCBArART/APSkE/S88sgLBQAAAgFiBgcCAnAICQIBIBYXAgHVCgsCAUgREgIBIAwNAK9BAjXwPtRNABggpiWgC+8uPr0yAx+kj6SPpI0z/TH9dMAaY8+CO58uPq0PoAMMjPk5HKTXISyz8T+lJY+gLJyM+FCBP6UoIQWf+B1s8LjvpSzMmBAKD7AIAfc+JHyQNcsJxMUKcyOYNT6SPoA10z4kviX7UTQ0x/TADH6SDAjxwXy4+gG0NTU1wsfUgm8jhAh+wQh0O0e7VNBB/ETJPgPkls14gHQ1ywn33tGhJUwVSDwAY4S1ywiMECBXDGUhA/y8OFVIPAC4uDXLCSgshF04wKED/LwgDgC1BAjXwPtRNABggpiWgC+8uPr0yAx+kj6SDH6SNM/0x/XTAGmPPgjvvLj6dD6APoAMMjPkzY6a0YTyz8B+gIB+gLJyM+FCBP6UoIQWf+B1s8LjvpSzMmBAKD7AIAH+1NTSB9MAAZPUbXOW1NRYgQCB4gLTAAGY0wT6SDCBAISUMG1tcOL4kviX7UTQAYIKrqVAvvLixdYf0gAg+kj6SDH6SDHTP9dMBPLT7wXHBfLj6AHQ+gAwggnJw4DIz5G8CeGiJc8LP1j6AsnIz4wEzmAVyz8dzBvMEszJyM+FCQ8B8hnKB4EAgSe6jiGBAIQjup9Ud1TIz4PLBM+FoMzM+RaaU3XIz4TQzMz5FuKTJ/kA4oEAhCS6jheDByahrqWwgwcmoQWACyfXJFjOQQTPAZQ0E8v/4lAJ+gJwzwtogQCBUAW6ljdbz4fAzOMNzMlw+wAByM7Pg87J7VQQADSBAIRQCLqaAs+GwBLLBM+FsJUwAc+GNuLMzAAkqyRsIe1E0NMfMQHIyx/Oye1UAfqpNmwS0NcsJKCyEXTyv9TU0gfTAAGT1G1zltTUWIEAgeIC0wABmNME+kgwgQCElDBtbXDi7UTQCoIKrqVAvvLixQnWH9IAIPpIMfpIMfpIMdM/10wD8tPvAtD6ADCCCcnDgMjPkbwJ4aIkzws/WPoCycjPjATOYBTLPxzMGhMC/szMycjPhQkYygeBAIEmuo4hgQCEK7qfVHZDyM+DywTPhaDMzPkWmlNkyM+E0MzM+Rbikyb5AOKBAIQsuo4Xgwcloa6lsIMHJaEEgAsm1yRYzlUCzwGUMxLL/+JQCPoCcM8LaIEAgVAEuphbNQTPh8AUzOMNE8zJcPsAyM7Pg84UFQA2gQCEUAi6mgHPhsAWywTPhbCUNs+GNuIVzBTMAAbJ7VQAM79aT2omhpkBj9JBj9JBj9JBjpn5jrhY/THkAgEgGBkCASAaGwIBIBwdAB22MB2omhpkBj9JBj9JBhAAI7as3aiaGmQGP0kGP0kGP0kGEAAvtaQ9qJoaZAY/SQY/SQY/SQY6Z+Y64WPwABG2S72omhrhY/Dj6M/i",
    );
    val update = XtrMasterUpdateContractAndProcessMessage.fromCell(updateBody);
    val updateData = update.updateData.load();
    val purchaseTxHash = "X6hC7v+cwomadT7YU1klcKwurXuUuyWh/PcvicUXV0w=";
    val purchaseBody = parseCellFromBase64(
        "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",
    );
    val purchase = XtrMasterPurchaseDispatch.fromCell(purchaseBody);

    expect(update.fromAddress).toEqual(
        address("0:1B3315F734D9154049E2375880C3B13B645630E8685A750FA7BB084CCACF7D91"),
    );
    expect(update.fromAmount).toEqual(80000000);
    expect(updateData.version).toEqual(0);
    expect(update.payload.hash()).toEqual(
        29223019327518469926561433991726366562356547530449407419254742575692373592767,
    );
    expect(purchase.payload.remainingBitsCount()).toEqual(0);
    expect(purchase.payload.remainingRefsCount()).toEqual(3);
    expect(update.toCell().hash()).toEqual(updateBody.hash());
    expect(purchase.toCell().hash()).toEqual(purchaseBody.hash());
    println(
        "XTR_UPDATE_TX={} FROM={} AMOUNT={} VERSION={} PAYLOAD_HASH={}",
        updateTxHash,
        update.fromAddress,
        update.fromAmount,
        updateData.version,
        update.payload.hash(),
    );
    println(
        "XTR_PURCHASE_DISPATCH_TX={} TAIL_REFS={}",
        purchaseTxHash,
        purchase.payload.remainingRefsCount(),
    );
}

get fun `test xtr master decodes real no-op body`() {
    val txHash = "9bM+LzeAfp3HZP0liKXblh2Inlc53cnIzsaw1EwhmN0=";
    val txLt = "68959606000003";
    val body = parseCellFromBase64("te6cckEBAQEABgAACL4wpG32PIXU");
    val message = XtrMasterNoop.fromCell(body);

    expect(message.toCell().hash()).toEqual(body.hash());
    println("XTR_NOOP_TX={} LT={}", txHash, txLt);
}
