import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/evaa_blank.types"
import "../wrappers/EvaaBlank.gen"

fun emptyTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun blankUpgradeHeaderWithoutInfo(): EvaaBlankUpgradeHeader {
    return EvaaBlankUpgradeHeader {
        userCodeVersion: 1,
        upgradeInfo: null,
        upgradeExec: 0,
    };
}

fun blankMissingUpgradeInfoBody(): cell {
    return beginCell()
        .storeCoins(1)
        .storeMaybeRef(null)
        .storeInt(0, 2)
        .endCell();
}

get fun `test evaa blank decodes missing upgrade info body`() {
    val body = blankMissingUpgradeInfoBody();
    val decoded = EvaaBlankIncomingUpgrade.fromCell(body);
    var commandTail = decoded.commandTail;

    expect(decoded.header.userCodeVersion).toEqual(1);
    expect(decoded.header.upgradeInfo).toBeNull();
    expect(decoded.header.upgradeExec).toEqual(0);
    expect(commandTail.remainingBitsCount()).toEqual(0);
    expect(commandTail.remainingRefsCount()).toEqual(0);
}

get fun `test evaa blank decodes local master upgrade header and emits revert call`() {
    val master = testing.treasury("evaa-blank-message-master");
    val owner = testing.treasury("evaa-blank-message-owner");
    val blank = EvaaBlank.fromStorage({
        platformAddress: master.address,
        ownerAddress: owner.address,
        typeId: 0,
        params: null,
        tail: emptyTail(),
    });

    blank.deploy(master.address, { value: ton("1"), bounce: false });

    val txs = blank.sendEvaaBlankIncomingUpgrade(
        master.address,
        blankUpgradeHeaderWithoutInfo(),
        emptyTail(),
        { value: ton("0.2"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx({
        from: master.address,
        to: blank.address,
        exitCode: EvaaBlankErrors.UserCodeVersionMismatch,
    });
    expect(txs).toHaveSuccessfulTx<EvaaBlankRevertCall>({
        from: blank.address,
        to: master.address,
        exitCode: 0,
    });
}
