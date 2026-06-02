import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v3r2.types"
import "../wrappers/WalletV3r2.gen"

const MAINNET_WALLET_V3R2_ADDRESS = "UQD75OBELEolVkzZ5Ak9CbHhTL5ivXhthGuKlescUX5vblSx"
const MAINNET_WALLET_V3R2_SEQNO = 3
const MAINNET_WALLET_V3R2_SUBWALLET_ID = 698983191

fun walletV3r2(): WalletV3r2 {
    return WalletV3r2.fromAddress(address(MAINNET_WALLET_V3R2_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell()
        .storeUint(0, 256)
        .storeUint(0, 256)
        .endCell()
        .beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyMessageStream(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV3r2StorageFromFork(wallet: WalletV3r2): WalletV3r2Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV3r2Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V3 R2 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V3 R2 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v3r2 mainnet getters through wrapper`() {
    val wallet = walletV3r2();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(MAINNET_WALLET_V3R2_SEQNO);
    expect(wallet.getPublicKey()).toBeGreater(0);
}

get fun `test wallet v3r2 mainnet parses persistent storage`() {
    val wallet = walletV3r2();
    val storage = loadWalletV3r2StorageFromFork(wallet);

    println("WALLET_V3R2_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V3R2_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(MAINNET_WALLET_V3R2_SUBWALLET_ID);
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
}

get fun `test wallet v3r2 mainnet accepts plain internal transfer`() {
    val wallet = walletV3r2();
    val sender = testing.treasury("wallet-v3r2-mainnet-plain-transfer");
    val beforeSeqno = wallet.seqno();

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
    expect(wallet.seqno()).toEqual(beforeSeqno);
}

get fun `test wallet v3r2 mainnet rejects invalid external signed request`() {
    val wallet = walletV3r2();

    val result = wallet.sendExternalWalletV3r2SignedExternal(
        zeroSignature(),
        MAINNET_WALLET_V3R2_SUBWALLET_ID as uint32,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptyMessageStream(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignatureOrExpiredMessage);
}
