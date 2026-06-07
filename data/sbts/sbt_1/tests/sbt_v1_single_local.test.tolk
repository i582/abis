import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "./test_utils"
import "../types/sbt_v1_single.types"
import "../wrappers/SbtV1Single.gen"

get fun `test sbt v1 single local getters and storage`() {
    val owner = testing.treasury("sbt-v1-single-local-owner");
    val editor = testing.treasury("sbt-v1-single-local-editor");
    val authority = testing.treasury("sbt-v1-single-local-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val storage = loadSbtV1SingleStorageFromFork(single);
    val data = single.getNftData();
    val editorAddress = single.getEditor();
    val authorityAddress = single.getAuthorityAddress();
    val revokedTime = single.getRevokedTime();

    expect(scripts.isContractDeployed(single.address)).toBeTrue();
    expect(data.isInitialized).toBeTrue();
    expect(data.itemIndex).toEqual(0);
    expect(data.collectionAddress).toBeNoneAddress();
    expect(data.ownerAddress).toEqual(storage.ownerAddress);
    expect(data.content.hash()).toEqual(storage.content.hash());
    expect(editorAddress).toEqual(storage.editorAddress);
    if (storage.authorityAddress == null) {
        expect(authorityAddress).toBeNoneAddress();
    } else {
        expect(authorityAddress.castToInternal()).toEqual(storage.authorityAddress!);
    }
    expect(revokedTime).toEqual(storage.revokedAt);

    println("SBT_V1_SINGLE_LOCAL_ADDRESS={}", single.address);
    println("SBT_V1_SINGLE_LOCAL_STORAGE={}", storage);
    println("SBT_V1_SINGLE_LOCAL_DATA={}", data);
    println("SBT_V1_SINGLE_LOCAL_EDITOR={}", editorAddress);
    println("SBT_V1_SINGLE_LOCAL_AUTHORITY={}", authorityAddress);
    println("SBT_V1_SINGLE_LOCAL_REVOKED_AT={}", revokedTime);
}

get fun `test sbt v1 single local get static data succeeds`() {
    val owner = testing.treasury("sbt-v1-single-local-static-owner");
    val editor = testing.treasury("sbt-v1-single-local-static-editor");
    val authority = testing.treasury("sbt-v1-single-local-static-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val sender = testing.treasury("sbt-v1-single-local-get-static-data");

    val txs = single.sendSbtV1SingleGetStaticData(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1SingleGetStaticData>({
        from: sender.address,
        to: single.address,
        exitCode: 0,
    });
}

get fun `test sbt v1 single local request owner succeeds`() {
    val owner = testing.treasury("sbt-v1-single-local-request-owner-owner");
    val editor = testing.treasury("sbt-v1-single-local-request-owner-editor");
    val authority = testing.treasury("sbt-v1-single-local-request-owner-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val sender = testing.treasury("sbt-v1-single-local-request-owner");

    val txs = single.sendSbtV1SingleRequestOwner(
        sender.address,
        2,
        sender.address,
        createEmptyCell(),
        false,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1SingleRequestOwner>({
        from: sender.address,
        to: single.address,
        exitCode: 0,
    });
}

get fun `test sbt v1 single local rejects transfer`() {
    val owner = testing.treasury("sbt-v1-single-local-transfer-owner");
    val editor = testing.treasury("sbt-v1-single-local-transfer-editor");
    val authority = testing.treasury("sbt-v1-single-local-transfer-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val sender = testing.treasury("sbt-v1-single-local-rejected-transfer");
    val before = single.getNftData();

    val txs = single.sendSbtV1SingleTransfer(
        sender.address,
        3,
        sender.address,
        null,
        null,
        0,
        sbtV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<SbtV1SingleTransfer>({
        from: sender.address,
        to: single.address,
        exitCode: SbtV1SingleErrors.TransferRejected,
    });
    expect(single.getNftData().ownerAddress).toEqual(before.ownerAddress);
}

get fun `test sbt v1 single local editor updates content`() {
    val owner = testing.treasury("sbt-v1-single-local-edit-owner");
    val editor = testing.treasury("sbt-v1-single-local-edit-editor");
    val authority = testing.treasury("sbt-v1-single-local-edit-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val newContent = beginCell().storeUint(0x45444954, 32).endCell();

    val txs = single.sendSbtV1SingleEditContent(
        editor.address,
        4,
        newContent,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1SingleEditContent>({
        from: editor.address,
        to: single.address,
        exitCode: 0,
    });
    expect(single.getNftData().content.hash()).toEqual(newContent.hash());
}

get fun `test sbt v1 single local rejects unauthorized edit content`() {
    val owner = testing.treasury("sbt-v1-single-local-unauth-edit-owner");
    val editor = testing.treasury("sbt-v1-single-local-unauth-edit-editor");
    val authority = testing.treasury("sbt-v1-single-local-unauth-edit-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val sender = testing.treasury("sbt-v1-single-local-unauthorized-edit-content");

    val txs = single.sendSbtV1SingleEditContent(
        sender.address,
        5,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<SbtV1SingleEditContent>({
        from: sender.address,
        to: single.address,
        exitCode: SbtV1SingleErrors.UnauthorizedEditContent,
    });
}

get fun `test sbt v1 single local transfers editorship`() {
    val owner = testing.treasury("sbt-v1-single-local-transfer-editor-owner");
    val editor = testing.treasury("sbt-v1-single-local-transfer-editor-editor");
    val authority = testing.treasury("sbt-v1-single-local-transfer-editor-authority");
    val newEditor = testing.treasury("sbt-v1-single-local-transfer-editor-new");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);

    val txs = single.sendSbtV1SingleTransferEditorship(
        editor.address,
        6,
        newEditor.address,
        null,
        false,
        0,
        sbtV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<SbtV1SingleTransferEditorship>({
        from: editor.address,
        to: single.address,
        exitCode: 0,
    });
    expect(single.getEditor()).toEqual(newEditor.address);
}

get fun `test sbt v1 single local rejects unauthorized transfer editorship`() {
    val owner = testing.treasury("sbt-v1-single-local-unauth-transfer-editor-owner");
    val editor = testing.treasury("sbt-v1-single-local-unauth-transfer-editor-editor");
    val authority = testing.treasury("sbt-v1-single-local-unauth-transfer-editor-authority");
    val single = deployLocalSbtV1Single(owner.address, editor.address, authority.address);
    val sender = testing.treasury("sbt-v1-single-local-unauthorized-transfer-editorship");

    val txs = single.sendSbtV1SingleTransferEditorship(
        sender.address,
        7,
        sender.address,
        null,
        false,
        0,
        sbtV1InlineEmptyForwardPayload(),
        { value: ton("0.1"), bounce: false },
    );

    expect(txs).toHaveFailedTx<SbtV1SingleTransferEditorship>({
        from: sender.address,
        to: single.address,
        exitCode: SbtV1SingleErrors.UnauthorizedOwnerAuthorityOrEditor,
    });
}
