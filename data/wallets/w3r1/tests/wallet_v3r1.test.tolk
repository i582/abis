import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_v3r1.types"
import "../wrappers/WalletV3r1.gen"

const MAINNET_WALLET_V3R1_ADDRESS = "UQCIUuaay7U5Sum5NPtF0e3iAAAvcR_IkOdtMP8MPNiysZQd"
const MAINNET_WALLET_V3R1_SEQNO = 48
const MAINNET_WALLET_V3R1_SUBWALLET_ID = 698983191

fun walletV3r1(): WalletV3r1 {
    return WalletV3r1.fromAddress(address(MAINNET_WALLET_V3R1_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyMessageStream(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadWalletV3r1StorageFromFork(wallet: WalletV3r1): WalletV3r1Storage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletV3r1Storage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Wallet V3 R1 mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Wallet V3 R1 mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet v3r1 mainnet getters through wrapper`() {
    val wallet = walletV3r1();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(MAINNET_WALLET_V3R1_SEQNO);
}

get fun `test wallet v3r1 mainnet parses persistent storage`() {
    val wallet = walletV3r1();
    val storage = loadWalletV3r1StorageFromFork(wallet);

    println("WALLET_V3R1_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_V3R1_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(MAINNET_WALLET_V3R1_SUBWALLET_ID);
    expect(storage.publicKey).toBeGreater(0);
}

get fun `test wallet v3r1 mainnet accepts plain internal transfer`() {
    val wallet = walletV3r1();
    val sender = testing.treasury("wallet-v3r1-mainnet-plain-transfer");
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

get fun `test wallet v3r1 mainnet rejects invalid external signed request`() {
    val wallet = walletV3r1();

    val result = wallet.sendExternalWalletV3r1SignedExternal(
        zeroSignature(),
        MAINNET_WALLET_V3R1_SUBWALLET_ID as uint32,
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptyMessageStream(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignatureOrExpiredMessage);
}
