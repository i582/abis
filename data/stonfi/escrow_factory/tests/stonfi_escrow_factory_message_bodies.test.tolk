import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_escrow_factory.types"

fun loadReferencedForwardPayload(mutate payload: RemainingBitsAndRefs): cell {
    expect(payload.remainingBitsCount()).toEqual(1);
    expect(payload.remainingRefsCount()).toEqual(1);
    expect(payload.loadBool()).toBeTrue();
    val body = payload.loadRef();
    expect(payload.remainingBitsCount()).toEqual(0);
    expect(payload.remainingRefsCount()).toEqual(0);
    return body;
}

get fun `test decodes real stonfi escrow factory transfer notification`() {
    val txHash = "puaMKsNjyJTicIdP7k3MsXwE24q2DCVVkzqv0n9P9E8=";
    val txLt = "86276837000016";
    val bodyBoc = "te6cckEBAQEANQAAZXNi0JwAAAAAAAAAAFG8DfqACAAZLTfMeBinOiH6EBTFAI0PaYqIpSDeyCQq8kY+5ldEJxoj2Bw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryJettonTransferNotification.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.jettonAmount == 0).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_TRANSFER_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real stonfi escrow factory init transfer`() {
    val txHash = "vnqS/UI/Cs6kpEg5RdVC3LKbtostr7/Fod5W39JgZF4=";
    val txLt = "79572421000003";
    val bodyBoc = "te6cckECBAEAARQAA6dHFt0WAAAAAAAAAADxP400PEpHfeAma+rFp42phqX73s+bZWNMTXhhYS8CuVYWxXIAACAGCzZOPoC0MWb+QmuQHa4dnDqe+sWxu3aUtug998wu7UQBAgMAjUAMFmycfQFoYs38hNcgO1w7OHU99Ytjdu0pbdB775hd2ogBysQvEa8N9t5KapO0D09cJmTE8enKMGQXSFNvOx/tyB5he+HoAAEBANmAGCzZOPoC0MWb+QmuQHa4dnDqe+sWxu3aUtug998wu7UQAcmO/cdpBY4NEFfGfD5PQhk6j8fOeS4g9XMkd0Qz9b4gCAGCzZOPoC0MWb+QmuQHa4dnDqe+sWxu3aUtug998wu7UAAAAAAR4aMB0X9ACg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryInitTransfer.fromCell(body);
    val bid = StonfiEscrowFactoryBidPaymentData.fromCell(decoded.bidPaymentData);
    val ask = StonfiEscrowFactoryAskRefundData.fromCell(decoded.askRefundData);
    val user = StonfiEscrowFactoryUserPaymentData.fromCell(decoded.userPaymentData);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.quoteId == 0).toBeFalse();
    expect(bid.amount + ask.amount + user.userReceiveAmount == 0).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_INIT_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real stonfi escrow factory ownership take`() {
    val txHash = "moS9yI+doOop+rHRzjwScf2hDIvaxp1JOjdD0aPpRyA=";
    val txLt = "79571752000016";
    val bodyBoc = "te6cckEBAQEAMAAAW4gSRhQAAAAAAAAAAIAHJz9gxe4/cgZvke8BCkMKLQcM5goGDPIwxCJBR4MiEtCA5rgG";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryTakeProtocolOwnership.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.excesses).toBeNotNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_TAKE_OWNERSHIP_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real stonfi escrow factory ownership offer`() {
    val txHash = "XB6lutw7xTm4M7YWEcWGMmVMG5aXo0yQfuiWg9uGeq0=";
    val txLt = "78257501000003";
    val bodyBoc = "te6cckEBAQEAUQAAnV34+jUAAAAAAAAAAIAIEf/sTFNE+SOKEBt1dc/FvahqWjSD1rw7Hanw/wv66fAA5OfsGL3H7kDN8j3gIUhhRaDhnMFAwZ5GGIRIKPBkQlqEUeWm";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryGiveProtocolOwnership.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newProtocolAddress).toBeNotNull();
    expect(decoded.excesses).toBeNotNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_GIVE_OWNERSHIP_TX={} LT={}", txHash, txLt);
}

get fun `test decodes successful stonfi escrow factory unlock notification and payload`() {
    val txHash = "gwQGOK6wahGj/oWgUXUs5qLlAWkV2b2i0AJSmyhc+1g=";
    val txLt = "79571284000025";
    val bodyBoc = "te6cckEBBAEAzAABZHNi0JwAAAAAahW+LkBfYIEYAevd5MAl9KBWzsRmA4Ph5NhYfZ8t75m18+DbN1pyX6tZAQKLalj4XOVsDBqVExYab1aASSd3nltgf7GLLUeuClLS0Fnom1PvgB693kwCX0oFbOxGYDg+Hk2Fh9ny3vmbXz4Ns3WnJfq1iAIDAIaAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWQA9e7yYBL6UCtnYjMBwfDybCw+z5b3zNr58G2brTkv1awAAtBnN5pEEAzGjLM";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryJettonTransferNotification.fromCell(body);
    var forwardPayload = decoded.forwardPayload;
    val unlock = StonfiEscrowFactoryUnlockPayload.fromCell(
        loadReferencedForwardPayload(mutate forwardPayload),
    );
    val unlockArgs = StonfiEscrowFactoryBilateralUnlockArgs.fromCell(unlock.unlockArgs);

    expect(decoded.queryId).toEqual(1779809838);
    expect(decoded.jettonAmount).toEqual(100010001);
    expect(unlock.quoteId == 0).toBeFalse();
    expect(unlockArgs.signed).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_UNLOCK_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real jetton transfer emitted by stonfi escrow factory`() {
    val txHash = "vnqS/UI/Cs6kpEg5RdVC3LKbtostr7/Fod5W39JgZF4=";
    val txLt = "79572421000003";
    val bodyBoc = "te6cckEBAQEAVQAApg+KfqUAAAAAAAAAADC98PgBgs2Tj6AtDFm/kJrkB2uHZw6nvrFsbt2lLboPffMLu1EAMFmycfQFoYs38hNcgO1w7OHU99Ytjdu0pbdB775hd2oAaa96Og==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryJettonTransfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.amount).toEqual(777999);
    expect(decoded.customPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_JETTON_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real vault deposit emitted by stonfi escrow factory`() {
    val txHash = "giyqOsbVkDbi/QjO2yicx5z6pY3dhL8JUETEXh4vLDw=";
    val txLt = "79571284000029";
    val bodyBoc = "te6cckEBAQEAMwAAYVVe30sAAAAAahW+LiJxGAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWAh0Kikk";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryVaultDepositTokens.fromCell(body);

    expect(decoded.queryId).toEqual(1779809838);
    expect(decoded.amount).toEqual(10001);
    expect(decoded.forwardPayload).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_VAULT_DEPOSIT_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real position unlock emitted by stonfi escrow factory`() {
    val txHash = "gwQGOK6wahGj/oWgUXUs5qLlAWkV2b2i0AJSmyhc+1g=";
    val txLt = "79571284000025";
    val bodyBoc = "te6cckEBAwEAxwACp2lvotgAAAAAahW+LiAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWQAmEBVU8VgLzGf2bJvEefQ7tz4i8Po5lOOefh/PjYSzi9AX2CBFAECAAtBnN5pEEAAyYAevd5MAl9KBWzsRmA4Ph5NhYfZ8t75m18+DbN1pyX6tZAD17vJgEvpQK2diMwHB8PJsLD7PlvfM2vnwbZutOS/VrIAevd5MAl9KBWzsRmA4Ph5NhYfZ8t75m18+DbN1pyX6tZAwPAhcw==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryPositionInternalUnlock.fromCell(body);
    val unlockArgs = StonfiEscrowFactoryBilateralUnlockArgs.fromCell(decoded.unlockArgs);

    expect(decoded.queryId).toEqual(1779809838);
    expect(decoded.resolverSentAmount).toEqual(100010001);
    expect(unlockArgs.signed).toBeNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_POSITION_UNLOCK_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real excesses emitted by stonfi escrow factory`() {
    val txHash = "vYQqs7w+DHNiGwEqp/DN8nE4dbVvaqsb6mUV2IBM1n0=";
    val txLt = "79571709000003";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryExcesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_EXCESSES_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real position lock emitted by stonfi escrow factory`() {
    val txHash = "kXV4fb7tmf8blpOQQTVvTX04cy3qtwUcM0Ic79AMi5Q=";
    val txLt = "79572040000021";
    val bodyBoc = "te6cckECEQEABP8AA6V6sGGBTE14YWEvArmAHKxC8Rrw323kpqk7QPT1wmZMTx6cowZBdIU287H+3IHmF74fADBZsnH0BaGLN/ITXIDtcOzh1PfWLY3btKW3Qe++YXdqEAECAwGTgA5Md+47SCxwaIK+M+HyehDJ1H4+c8lxB6uZI7ohn63xEALCJFmt9RKUwzR3P4ebgpbUipoXPU/DGDf63SNAO3fqoADJAjw0YAIEAVqAHr3eTAJfSgVs7EZgOD4eTYWH2fLe+ZtfPg2zdacl+rWAAAAAAAAADwasYVAFBMgighAGasEAuuMCIoIQf9mkbrrjAjEhghCNnDfUuo4yW+1E0NQx10wg0PoAMfpAMdM/10zQ+COCAMswA7wS8vT6ADHTAAGT0/8x3voAMHBmbwTgIYIQZTsQ/7rjAiGCEF70stO6BgcICQDJgBYidTKWoElCzjPtInJlHW6ysthxRL6yBRYo39m4bEO/0AMFmycfQFoYs38hNcgO1w7OHU99Ytjdu0pbdB775hd2ogBgs2Tj6AtDFm/kJrkB2uHZw6nvrFsbt2lLboPffMLu1EAADBNWMKgAHgH+Mm8V1ywj1YMMDPK/0z8x+kAx+gAwAdD6QNM/+gDTAAGS0/+SbQHi1NGCAMshJMMA8vSCAMsiI8MA8vSCAMslJfpEMMAA8vQg0NMDggDLJCLBCPL0JAKOGPoA0w8iggDLIwW7FPL0ggDLMwHCAPL0AeSCAMsyMscA8vT4I1AEoAoB8GwS7UTQ1DHXTCDQ+gD6QNM/+gDXTND6ANMAAZLT/5JtAeL6ANTRCm8V1ywjS30WxPK/00Ex+kD6QDH6ADCCAMsnKcMA8vSCAMsoIvpEMMAA8vT4I1MHu44dMFBqXwU2ggDLKQLHBfL0ggDLKlFDuhTy9FlwbwTjDgsAiFvtRNDUMddMIND6ADH6QDHTP9dM0PgjAfoAMdMAAZPT/zHe+gDXTNDTAwGY+gAx0w8EoAPkMAGCAMsxA7wS8vRwZm8EAaKOP1vtRNDTB9Qx10yCAIdjIsMClQLDA8MAkjJw4hLy9ND6ADH6QDHTP9dM0NdM0NMDAZj6ADHTDwKgAeQwpCBvAuABggnnri+64wKCANj08vAQAFbIJvoCIm6UbBLPgZXPgxLL/+LPhCATzMnIUAX6AhPOyz8B+gLMyXBTAG8EAcA6CtD6APoA0wABmYMI1xjXTIEAhJQwbW1w4iduk18DMo40ggDLKwHAALOaIfkAVBA4+RDDAJIycOIS8vTQ0z/6QNGCAMspBccFFPL0ggDLL1E7vBPy9OIr0NMDVCBzUp0MA/yONe2i7fsEjicC+gDTD1NBoFNgu44VW1MwoFJVoVBFoRKoA6gSoAGpBNsx4DI0bBLkggDLLPLw2FR4oKmEcFR8FryOFjAxJVQyKqmEU8ChUgW8kjE7kjAy4gqUEC1sMuJRSqGCAMstIcL/8vSCAMsuUau7GvL0IXAqwgDjD8gNDg8ACDNQBKAACFsDoHAAVFAJ+gIibpRsEs+Blc+DEsv/4lAH+gIYzMnIUAX6AhPOyz8B+gLMyQNvBADa0O1E0NQx10zQ+gAx+kAx0z/6ANdM0APTAAGT1ws/kjBt4iBus5Mw+CPfA9dM0NMDUDMEjjXtou37BI4nAvoA0w9TQaBTYLuOFVtTMKBSVaFQRaESqAOoEqABqQTbMeAyNGwS5IIAyyzy8NhvATdqO/0=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonfiEscrowFactoryPositionInternalLock.fromCell(body);
    val metadata = StonfiEscrowFactoryPositionLockMetadata.fromCell(decoded.additionalField);
    val lockArgs = StonfiEscrowFactoryBilateralLockArgs.fromCell(decoded.lockArgs);
    val more = StonfiEscrowFactoryPositionLockMetadataMore.fromCell(metadata.more);
    val segments = StonfiEscrowFactoryDutchSegments.fromCell(lockArgs.dutchSegments);

    expect(decoded.queryId == 0).toBeFalse();
    expect(decoded.amount == 0).toBeFalse();
    expect(metadata.refFeeTier).toEqual(50);
    expect(more.orderOwner).toBeNotNull();
    expect(segments.count == 0).toBeFalse();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_ESCROW_FACTORY_POSITION_LOCK_TX={} LT={}", txHash, txLt);
}
