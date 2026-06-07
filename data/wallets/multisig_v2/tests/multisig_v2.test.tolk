import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/multisig_order_v2.types"
import "../types/multisig_v2.types"
import "../wrappers/MultisigOrderV2.gen"
import "../wrappers/MultisigV2.gen"

const MAINNET_MULTISIG_V2_ADDRESS = "EQDBiZgqlvtO7yyHUU-W76fFAMq_DNa0_usZYgcpjNIfRVFI"
const MAINNET_MULTISIG_ORDER_V2_ADDRESS = "EQC9p_dC5dRmLnrV8fl5sRXrbWAqGoPa37ROSvjurK60dUFN"

fun mainnetMultisigV2(): MultisigV2 {
    return MultisigV2.fromAddress(address(MAINNET_MULTISIG_V2_ADDRESS));
}

fun mainnetMultisigOrderV2(): MultisigOrderV2 {
    return MultisigOrderV2.fromAddress(address(MAINNET_MULTISIG_ORDER_V2_ADDRESS));
}

fun maxOrderSeqno(): uint256 {
    return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff as uint256;
}

fun futureExpirationDate(): uint48 {
    return (blockchain.now() + 1000) as uint48;
}

fun emptyTextCommentTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun unknownBodyWithQuery(): cell {
    return beginCell().storeUint(0x12345678, 32).storeUint(0, 64).endCell();
}

fun loadMultisigV2StorageFromFork(multisig: MultisigV2): MultisigV2Storage {
    val account = testing.getAccountState(multisig.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MultisigV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Multisig V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Multisig V2 mainnet fixture account is frozen");
        }
    }
}

fun loadMultisigOrderV2StorageFromFork(order: MultisigOrderV2): MultisigOrderV2Storage {
    val account = testing.getAccountState(order.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MultisigOrderV2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Multisig Order V2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Multisig Order V2 mainnet fixture account is frozen");
        }
    }
}

fun loadMultisigOrderV2DeploymentStorageFromFork(
    order: MultisigOrderV2,
): MultisigOrderV2DeploymentStorage {
    val account = testing.getAccountState(order.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MultisigOrderV2DeploymentStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Multisig Order V2 deployment fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Multisig Order V2 deployment fixture account is frozen");
        }
    }
}

get fun `test multisig v2 mainnet getters through wrapper`() {
    val multisig = mainnetMultisigV2();

    expect(scripts.isContractDeployed(multisig.address)).toBeTrue();

    val data = multisig.getMultisigData();
    val estimate = multisig.getOrderEstimate(createEmptyCell(), blockchain.now() + 1000);
    val orderAddressZero = multisig.getOrderAddress(0);

    println("MULTISIG_V2_ADDRESS={}", multisig.address);
    println("MULTISIG_V2_DATA={}", data);
    println("MULTISIG_V2_ORDER_ESTIMATE_EMPTY={}", estimate);
    println("MULTISIG_V2_ORDER_ADDRESS_0={}", orderAddressZero);

    expect(data.threshold).toBeGreater(0);
    expect(estimate).toBeGreater(0);
}

get fun `test multisig v2 mainnet parses persistent storage`() {
    val multisig = mainnetMultisigV2();
    val storage = loadMultisigV2StorageFromFork(multisig);
    val data = multisig.getMultisigData();

    println("MULTISIG_V2_STORAGE_ADDRESS={}", multisig.address);
    println("MULTISIG_V2_STORAGE={}", storage);

    if (storage.allowArbitraryOrderSeqno) {
        expect(data.seqno).toEqual(-1);
    } else {
        expect(data.seqno).toEqual(storage.nextOrderSeqno);
    }
    expect(data.threshold).toEqual(storage.threshold);
    expect(data.signers.hash()).toEqual(storage.signers.hash());

    expect(data.proposers).toHaveLength(1);
    expect(storage.proposers).toHaveLength(1);
    expect(data.proposers).toContainKey(0 as uint8);
    expect(storage.proposers).toContainKey(0 as uint8);
    expect(data.proposers.mustGet(0 as uint8)).toEqual(storage.proposers.mustGet(0 as uint8));
}

get fun `test multisig order v2 mainnet parses deployment storage and parent relation`() {
    val order = mainnetMultisigOrderV2();
    val storage = loadMultisigOrderV2DeploymentStorageFromFork(order);
    val data = order.getOrderData();
    val parent = MultisigV2.fromAddress(storage.multisigAddress);
    val expectedOrderAddress = parent.getOrderAddress(storage.orderSeqno as int);

    println("MULTISIG_ORDER_V2_ADDRESS={}", order.address);
    println("MULTISIG_ORDER_V2_DEPLOYMENT_STORAGE={}", storage);
    println("MULTISIG_ORDER_V2_DEPLOYMENT_DATA={}", data);
    println("MULTISIG_ORDER_V2_PARENT={}", parent.address);

    expect(scripts.isContractDeployed(order.address)).toBeTrue();
    expect(scripts.isContractDeployed(parent.address)).toBeTrue();
    expect(expectedOrderAddress).toEqual(order.address);
    expect(data.multisigAddress).toEqual(storage.multisigAddress);
    expect(data.orderSeqno).toEqual(storage.orderSeqno as int);
    expect(data.threshold).toBeNull();
    expect(data.sentForExecution).toBeNull();
    expect(data.signers).toBeNull();
    expect(data.approvalsMask).toBeNull();
    expect(data.approvalsNum).toBeNull();
    expect(data.expirationDate).toBeNull();
    expect(data.order).toBeNull();
}

get fun `test multisig order v2 local initialized getter after source init`() {
    val parent = testing.treasury("multisig-order-v2-local-parent");
    val multisigStorage = loadMultisigV2StorageFromFork(mainnetMultisigV2());
    val order = MultisigOrderV2.fromStorage({
        multisigAddress: parent.address,
        orderSeqno: 42,
    });

    if (order.stateInit == null) {
        Assert.fail("Expected MultisigOrderV2.fromStorage to produce StateInit");
    }
    val initTxs = net.send(
        parent.address,
        createMessage({
            bounce: false,
            value: ton("0.2"),
            dest: { stateInit: order.stateInit! },
            body: MultisigOrderV2Init {
                queryId: 3,
                threshold: 2,
                signers: multisigStorage.signers,
                expirationDate: futureExpirationDate(),
                order: createEmptyCell(),
                signerIndexOnInit: null,
            },
        }),
    );

    expect(initTxs).toHaveSuccessfulTx<MultisigOrderV2Init>({
        from: parent.address,
        to: order.address,
        exitCode: 0,
    });

    val storage = loadMultisigOrderV2StorageFromFork(order);
    val data = order.getOrderData();

    println("MULTISIG_ORDER_V2_LOCAL_INITIALIZED_ADDRESS={}", order.address);
    println("MULTISIG_ORDER_V2_LOCAL_INITIALIZED_STORAGE={}", storage);
    println("MULTISIG_ORDER_V2_LOCAL_INITIALIZED_DATA={}", data);

    expect(data.multisigAddress).toEqual(storage.multisigAddress);
    expect(data.orderSeqno).toEqual(storage.orderSeqno as int);
    expect(data.threshold).toBeNotNull();
    expect(data.threshold!).toEqual(storage.threshold as int);
    expect(data.sentForExecution).toBeNotNull();
    expect(data.sentForExecution!).toEqual(storage.sentForExecution);
    expect(data.signers).toBeNotNull();
    expect(data.signers!.hash()).toEqual(storage.signers.hash());
    expect(data.approvalsMask).toBeNotNull();
    expect(data.approvalsMask!).toEqual(storage.approvalsMask as int);
    expect(data.approvalsNum).toBeNotNull();
    expect(data.approvalsNum!).toEqual(storage.approvalsNum as int);
    expect(data.expirationDate).toBeNotNull();
    expect(data.expirationDate!).toEqual(storage.expirationDate as int);
    expect(data.order).toBeNotNull();
    expect(data.order!.hash()).toEqual(storage.order.hash());
}

get fun `test multisig v2 mainnet accepts plain internal transfer`() {
    val multisig = mainnetMultisigV2();
    val sender = testing.treasury("multisig-v2-mainnet-plain-transfer");

    val txs = multisig.sendAny(
        sender.address,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: multisig.address,
        exitCode: 0,
    });
}

get fun `test multisig v2 mainnet accepts typed text comment`() {
    val multisig = mainnetMultisigV2();
    val sender = testing.treasury("multisig-v2-mainnet-text-comment");

    val txs = multisig.sendMultisigV2TextComment(
        sender.address,
        emptyTextCommentTail(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx<MultisigV2TextComment>({
        from: sender.address,
        to: multisig.address,
        exitCode: 0,
    });
}

get fun `test multisig v2 mainnet rejects unauthorized new order`() {
    val multisig = mainnetMultisigV2();
    val sender = testing.treasury("multisig-v2-mainnet-unauthorized-new-order");

    val txs = multisig.sendMultisigV2NewOrder(
        sender.address,
        1,
        maxOrderSeqno(),
        true,
        0,
        futureExpirationDate(),
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<MultisigV2NewOrder>({
        from: sender.address,
        to: multisig.address,
        exitCode: MultisigV2Errors.UnauthorizedNewOrder,
    });
}

get fun `test multisig order v2 mainnet rejects unauthorized approval`() {
    val order = mainnetMultisigOrderV2();
    val sender = testing.treasury("multisig-order-v2-mainnet-unauthorized-approval");

    val txs = order.sendMultisigOrderV2Approve(
        sender.address,
        2,
        0,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<MultisigOrderV2Approve>({
        from: sender.address,
        to: order.address,
        exitCode: MultisigOrderV2Errors.UnauthorizedSign,
    });
}

get fun `test multisig order v2 mainnet rejects unknown opcode`() {
    val order = mainnetMultisigOrderV2();
    val sender = testing.treasury("multisig-order-v2-mainnet-unknown-op");

    val txs = order.sendAny(
        sender.address,
        unknownBodyWithQuery(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx({
        from: sender.address,
        to: order.address,
        exitCode: MultisigOrderV2Errors.UnknownOp,
    });
}
