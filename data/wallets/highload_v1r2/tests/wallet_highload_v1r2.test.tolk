import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_highload_v1r2.types"
import "../wrappers/WalletHighloadV1r2.gen"

const TEST_SUBWALLET_ID = 698983191
const TEST_PUBLIC_KEY = 1

fun walletHighloadV1r2Storage(): WalletHighloadV1r2Storage {
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

fun deployWalletHighloadV1r2(): WalletHighloadV1r2 {
    val sender = testing.treasury("wallet-highload-v1r2-local-deployer");
    val wallet = WalletHighloadV1r2.fromStorage(walletHighloadV1r2Storage());

    val txs = wallet.deploy(sender.address, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: sender.address,
        to: wallet.address,
        exitCode: 0,
    });

    return wallet;
}

fun loadWalletHighloadV1r2Storage(wallet: WalletHighloadV1r2): WalletHighloadV1r2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletHighloadV1r2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Highload Wallet V1 R2 local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Highload Wallet V1 R2 local fixture account is frozen");
        }
    }
}

get fun `test highload wallet v1r2 local getters through wrapper`() {
    val wallet = deployWalletHighloadV1r2();

    expect(wallet.seqno()).toEqual(0);
    expect(wallet.getPublicKey()).toEqual(TEST_PUBLIC_KEY);
}

get fun `test highload wallet v1r2 local parses persistent storage`() {
    val wallet = deployWalletHighloadV1r2();
    val storage = loadWalletHighloadV1r2Storage(wallet);

    println("WALLET_HIGHLOAD_V1R2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_HIGHLOAD_V1R2_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(TEST_SUBWALLET_ID);
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
}

get fun `test highload wallet v1r2 local accepts plain internal transfer without changing seqno`() {
    val wallet = deployWalletHighloadV1r2();
    val sender = testing.treasury("wallet-highload-v1r2-local-plain-transfer");

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

get fun `test highload wallet v1r2 local rejects expired external request`() {
    val wallet = deployWalletHighloadV1r2();

    val result = wallet.sendExternalHighloadWalletSignedV1r2(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        0,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.ExpiredOrInvalidSignature);
}

get fun `test highload wallet v1r2 local rejects invalid external seqno`() {
    val wallet = deployWalletHighloadV1r2();

    val result = wallet.sendExternalHighloadWalletSignedV1r2(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno() + 1,
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSeqno);
}

get fun `test highload wallet v1r2 local rejects invalid external subwallet id`() {
    val wallet = deployWalletHighloadV1r2();

    val result = wallet.sendExternalHighloadWalletSignedV1r2(
        zeroSignature(),
        (TEST_SUBWALLET_ID + 1) as uint32,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSubwalletId);
}

get fun `test highload wallet v1r2 local rejects invalid external signature`() {
    val wallet = deployWalletHighloadV1r2();

    val result = wallet.sendExternalHighloadWalletSignedV1r2(
        zeroSignature(),
        TEST_SUBWALLET_ID,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        externalPayloadProbe(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.ExpiredOrInvalidSignature);
}
