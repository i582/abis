import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v1r1.types"
import "../wrappers/WalletHighloadV1r1.gen"

const TEST_SUBWALLET_ID = 698983191
const TEST_PUBLIC_KEY = 1

fun walletHighloadV1r1Storage(): WalletHighloadV1r1Storage {
    return {
        seqno: 0,
        subwalletId: TEST_SUBWALLET_ID,
        publicKey: TEST_PUBLIC_KEY,
    };
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun externalPayloadProbe(): cell {
    return createEmptyCell();
}

fun deployWalletHighloadV1r1(): WalletHighloadV1r1 {
    val sender = testing.treasury("wallet-highload-v1r1-local-deployer");
    val wallet = WalletHighloadV1r1.fromStorage(walletHighloadV1r1Storage());

    val txs = wallet.deploy(sender.address, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });

    return wallet;
}

fun loadWalletHighloadV1r1Storage(wallet: WalletHighloadV1r1): WalletHighloadV1r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV1r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V1 R1 local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V1 R1 local fixture account is frozen");
        }
    }
}

get fun `test highload wallet v1r1 local getters through wrapper`() {
    val wallet = deployWalletHighloadV1r1();

    expect(wallet.seqno()).toEqual(0);
}

get fun `test highload wallet v1r1 local parses persistent storage`() {
    val wallet = deployWalletHighloadV1r1();
    val storage = loadWalletHighloadV1r1Storage(wallet);

    println("WALLET_HIGHLOAD_V1R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V1R1_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(TEST_SUBWALLET_ID);
    expect(storage.publicKey).toEqual(TEST_PUBLIC_KEY);
}

get fun `test highload wallet v1r1 local accepts plain internal transfer without changing seqno`() {
    val wallet = deployWalletHighloadV1r1();
    val sender = testing.treasury("wallet-highload-v1r1-local-plain-transfer");

    val txs = wallet.sendAny(
        sender.address,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });
    expect(wallet.seqno()).toEqual(0);
}

get fun `test highload wallet v1r1 local rejects expired external request`() {
    val wallet = deployWalletHighloadV1r1();

    val result = wallet.sendExternalHighloadWalletSignedV1r1(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        0,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.ExpiredOrInvalidSignature);
}

get fun `test highload wallet v1r1 local rejects invalid external seqno`() {
    val wallet = deployWalletHighloadV1r1();

    val result = wallet.sendExternalHighloadWalletSignedV1r1(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno() + 1,
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSeqno);
}

get fun `test highload wallet v1r1 local rejects invalid external subwallet id`() {
    val wallet = deployWalletHighloadV1r1();

    val result = wallet.sendExternalHighloadWalletSignedV1r1(
        zeroSignature(),
        (TEST_SUBWALLET_ID + 1) as uint32,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSubwalletId);
}

get fun `test highload wallet v1r1 local rejects invalid external signature`() {
    val wallet = deployWalletHighloadV1r1();

    val result = wallet.sendExternalHighloadWalletSignedV1r1(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.ExpiredOrInvalidSignature);
}
