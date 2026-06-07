import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_2_master.types"
import "../types/jetton_2_wallet.types"
import "../wrappers/Jetton2Master.gen"
import "../wrappers/Jetton2Wallet.gen"

const JETTON_2_SHARD_DEPTH = 8

fun jetton2InlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun localJetton2Master(admin: address): Jetton2Master {
    return Jetton2Master.fromStorage({
        totalSupply: 0,
        adminAddress: admin,
        nextAdminAddress: null,
        jettonWalletCode: build("Jetton2Wallet"),
        metadataUri: createEmptyCell(),
    });
}

fun deployLocalJetton2Master(admin: address): Jetton2Master {
    val master = localJetton2Master(admin);
    if (master.stateInit == null) {
        Assert.fail("Jetton v2.0 local master wrapper has no state init");
    }
    val deployMsg = createMessage({
        bounce: false,
        value: ton("1"),
        dest: { stateInit: master.stateInit },
        body: Jetton2MasterTopUp { queryId: 0 },
    });
    val txs = net.send(admin, deployMsg);
    expect(txs).toHaveSuccessfulDeploy<Jetton2MasterTopUp>({
        from: admin,
        to: master.address,
        exitCode: 0,
    });
    expect(testing.isDeployed(master.address)).toBeTrue();
    return master;
}

fun localJetton2WalletInitial(master: Jetton2Master, owner: address): Jetton2Wallet {
    return Jetton2Wallet.fromStorage(
        {
            balance: 0,
            ownerAddress: owner,
            jettonMasterAddress: master.address,
        },
        { fixedPrefixLength: JETTON_2_SHARD_DEPTH as uint5, closeTo: owner },
    );
}

fun mintToLocalJetton2Wallet(
    master: Jetton2Master,
    admin: address,
    owner: address,
    queryId: uint64,
    amount: coins,
): Jetton2Wallet {
    val wallet = localJetton2WalletInitial(master, owner);
    val mintTxs = master.sendJetton2MasterMint(
        admin,
        queryId,
        owner,
        ton("0.25"),
        {
            queryId,
            amount,
            from: null,
            responseAddress: admin,
            forwardTonAmount: 0,
            forwardPayload: jetton2InlineEmptyForwardPayload(),
        },
        { value: ton("0.5"), bounce: false },
    );

    expect(mintTxs).toHaveSuccessfulTx<Jetton2MasterMint>({
        from: admin,
        to: master.address,
        exitCode: 0,
    });
    expect(mintTxs).toHaveSuccessfulDeploy<Jetton2WalletInternalTransfer>({
        from: master.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(testing.isDeployed(wallet.address)).toBeTrue();
    return Jetton2Wallet.fromAddress(wallet.address);
}

fun loadLocalJetton2MasterStorage(master: Jetton2Master): Jetton2MasterStorage {
    val account = testing.getAccountState(master.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return Jetton2MasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton v2.0 local master account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton v2.0 local master account is frozen");
        }
    }
}

fun loadLocalJetton2WalletStorage(wallet: Jetton2Wallet): Jetton2WalletStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return Jetton2WalletStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Jetton v2.0 local wallet account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Jetton v2.0 local wallet account is frozen");
        }
    }
}
