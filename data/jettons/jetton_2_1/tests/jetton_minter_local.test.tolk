import "@stdlib/strings"
import "@acton/io"
import "@acton/build"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/jetton_minter.types"
import "../wrappers/JettonMinter.gen"

fun buildJetton21Metadata(uri: string): cell {
    var metadata: OnchainMetadataReply = { contentDict: [] };
    metadata.contentDict.set("uri".sha256(), uri.prefixWith00());
    return metadata.toCell();
}

fun emptyJetton21ForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun deployJetton21Minter(admin: address): JettonMinter {
    val minter = JettonMinter.fromStorage({
        totalSupply: 0,
        adminAddress: admin,
        nextAdminAddress: null,
        metadata: buildJetton21Metadata("https://example.com/jetton.json"),
    });
    if (minter.stateInit == null) {
        Assert.fail("JettonMinter wrapper has no state init");
    }

    val txs = net.send(
        admin,
        createMessage({
            bounce: false,
            value: ton("1"),
            dest: { stateInit: minter.stateInit! },
            body: TopUpTons {},
        }),
    );
    expect(txs).toHaveSuccessfulDeploy<TopUpTons>({
        from: admin,
        to: minter.address,
        exitCode: 0,
    });
    return minter;
}

fun loadJetton21MinterStorage(minter: JettonMinter): MinterStorage {
    val account = testing.getAccountState(minter.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return MinterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("JettonMinter account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("JettonMinter account is frozen");
        }
    }
}

get fun `test jetton 2.1 minter local getters and storage`() {
    val admin = testing.treasury("jetton-2-1-minter-admin");
    val owner = testing.treasury("jetton-2-1-minter-owner");
    val minter = deployJetton21Minter(admin.address);
    val storage = loadJetton21MinterStorage(minter);
    val data = minter.getJettonData();
    val walletAddress = minter.getWalletAddress(owner.address);

    expect(data.totalSupply).toEqual(storage.totalSupply);
    expect(data.mintable).toBeTrue();
    expect(data.adminAddress).toEqual(admin.address);
    expect(data.jettonContent.hash()).toEqual(storage.metadata.hash());
    expect(data.jettonWalletCode.hash()).toEqual(build("JettonWallet").hash());
    expect(minter.getNextAdminAddress()).toBeNull();
    expect(walletAddress.getWorkchain()).toEqual(0);

    println("JETTON_2_1_MINTER_STORAGE={}", storage);
    println("JETTON_2_1_MINTER_DATA={}", data);
    println("JETTON_2_1_MINTER_WALLET_ADDRESS={}", walletAddress);
}

get fun `test jetton 2.1 minter mints and rejects unauthorized admin`() {
    val admin = testing.treasury("jetton-2-1-minter-mint-admin");
    val owner = testing.treasury("jetton-2-1-minter-mint-owner");
    val attacker = testing.treasury("jetton-2-1-minter-attacker");
    val minter = deployJetton21Minter(admin.address);
    val walletAddress = minter.getWalletAddress(owner.address);

    val mintTxs = minter.sendMintNewJettons(
        admin.address,
        21,
        owner.address,
        ton("0.25"),
        {
            queryId: 21,
            jettonAmount: 1000,
            transferInitiator: null,
            sendExcessesTo: admin.address,
            forwardTonAmount: 0,
            forwardPayload: emptyJetton21ForwardPayload(),
        },
        { value: ton("0.5"), bounce: false },
    );
    expect(mintTxs).toHaveSuccessfulTx<MintNewJettons>({
        from: admin.address,
        to: minter.address,
        exitCode: 0,
    });
    expect(mintTxs).toHaveSuccessfulDeploy<InternalTransferStep>({
        from: minter.address,
        to: walletAddress,
        exitCode: 0,
    });
    expect(testing.isDeployed(walletAddress)).toBeTrue();
    expect(minter.getJettonData().totalSupply).toEqual(1000);

    val rejectedTxs = minter.sendChangeMinterAdmin(
        attacker.address,
        22,
        attacker.address,
        { value: ton("0.05"), bounce: false },
    );
    expect(rejectedTxs).toHaveFailedTx<ChangeMinterAdmin>({
        from: attacker.address,
        to: minter.address,
        exitCode: Errors.NotOwner,
    });
    expect(minter.getJettonData().adminAddress).toEqual(admin.address);
}
