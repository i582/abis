import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/lockup_universal.types"
import "../wrappers/LockupUniversal.gen"

const MAINNET_LOCKUP_UNIVERSAL_ADDRESS = "UQCp5d6J6Wp0HEvRpH3we8th9rs59A0EWczIlv6nIBYA5A6R"

fun lockupUniversal(): LockupUniversal {
    return LockupUniversal.fromAddress(address(MAINNET_LOCKUP_UNIVERSAL_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyMessageStream(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun loadLockupUniversalStorageFromFork(wallet: LockupUniversal): LockupUniversalStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return LockupUniversalStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("LockupUniversal mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("LockupUniversal mainnet fixture account is frozen");
        }
    }
}

get fun `test lockup universal mainnet getters through wrapper`() {
    val wallet = lockupUniversal();
    val storage = loadLockupUniversalStorageFromFork(wallet);
    val balances = wallet.getBalances();

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(storage.seqno);
    expect(wallet.walletId()).toEqual(storage.subwalletId);
    expect(wallet.getPublicKey()).toEqual(storage.publicKey);
    expect(balances.tonBalance).toBeGreater(0);
    expect(wallet.getBalancesAt(blockchain.now()).tonBalance).toEqual(balances.tonBalance);
}

get fun `test lockup universal mainnet parses persistent storage`() {
    val wallet = lockupUniversal();
    val storage = loadLockupUniversalStorageFromFork(wallet);

    println("LOCKUP_UNIVERSAL_STORAGE_ADDRESS={}", wallet.address);
    println("LOCKUP_UNIVERSAL_STORAGE={}", storage);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(storage.configPublicKey).toBeGreater(0);
}

get fun `test lockup universal mainnet accepts plain internal transfer`() {
    val wallet = lockupUniversal();
    val sender = testing.treasury("lockup-universal-mainnet-plain-transfer");
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

get fun `test lockup universal mainnet rejects invalid external signed request`() {
    val wallet = lockupUniversal();

    val result = wallet.sendExternalLockupUniversalSignedExternal(
        zeroSignature(),
        wallet.walletId(),
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptyMessageStream(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.WrongSignature);
}
