import "@stdlib/lisp-lists"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/wallet_vesting.types"
import "../wrappers/WalletVesting.gen"

const MAINNET_WALLET_VESTING_ADDRESS = "UQCufmEfMOiP1SFMCZwKXpKEWn34vei9EYT2f0YNPqhdOe0o"

fun walletVesting(): WalletVesting {
    return WalletVesting.fromAddress(address(MAINNET_WALLET_VESTING_ADDRESS));
}

fun zeroSignature(): bits512 {
    var signature = beginCell().storeUint(0, 256).storeUint(0, 256).endCell().beginParse();
    return signature.loadBits(512) as bits512;
}

fun emptyOutgoingTail(): RemainingBitsAndRefs {
    return createEmptyCell().beginParse();
}

fun zeroAddress(): address {
    return address("0:0000000000000000000000000000000000000000000000000000000000000000");
}

fun loadWalletVestingStorageFromFork(wallet: WalletVesting): WalletVestingStorage {
    val account = testing.getAccountState(wallet.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return WalletVestingStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("WalletVesting mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("WalletVesting mainnet fixture account is frozen");
        }
    }
}

get fun `test wallet vesting mainnet getters through wrapper`() {
    val wallet = walletVesting();
    val storage = loadWalletVestingStorageFromFork(wallet);
    val vestingData = wallet.getVestingData();
    val whitelist = wallet.getWhitelist();
    val lockedNow = wallet.getLockedAmount(blockchain.now());

    expect(scripts.isContractDeployed(wallet.address)).toBeTrue();
    expect(wallet.seqno()).toEqual(storage.seqno);
    expect(wallet.getSubwalletId()).toEqual(storage.subwalletId);
    expect(wallet.getPublicKey()).toEqual(storage.publicKey);
    expect(vestingData.vestingTotalDuration).toBeGreater(0);
    expect(vestingData.unlockPeriod).toBeGreater(0);
    expect(vestingData.cliffDuration).toBeGreaterOrEqual(0);
    expect(vestingData.vestingTotalAmount).toBeGreaterOrEqual(0);
    expect(lockedNow).toBeGreaterOrEqual(0);
    expect(whitelist.calculateSize()).toBeGreaterOrEqual(0);
    expect(wallet.isWhitelisted(zeroAddress())).toBeFalse();

    println("WALLET_VESTING_DATA={}", vestingData);
    println("WALLET_VESTING_WHITELIST={}", whitelist);
    println("WALLET_VESTING_LOCKED_NOW={}", lockedNow);
}

get fun `test wallet vesting mainnet parses persistent storage`() {
    val wallet = walletVesting();
    val storage = loadWalletVestingStorageFromFork(wallet);
    val params = WalletVestingParameters.fromCell(storage.vesting);
    val vestingData = wallet.getVestingData();

    println("WALLET_VESTING_STORAGE_ADDRESS={}", wallet.address);
    println("WALLET_VESTING_STORAGE={}", storage);
    println("WALLET_VESTING_STORAGE_PARAMS={}", params);
    println("WALLET_VESTING_STORAGE_WHITELIST={}", storage.whitelist);

    expect(storage.seqno).toEqual(wallet.seqno());
    expect(storage.subwalletId).toEqual(wallet.getSubwalletId());
    expect(storage.publicKey).toEqual(wallet.getPublicKey());
    expect(params.vestingStartTime).toEqual(vestingData.vestingStartTime);
    expect(params.vestingTotalDuration).toEqual(vestingData.vestingTotalDuration);
    expect(params.unlockPeriod).toEqual(vestingData.unlockPeriod);
    expect(params.cliffDuration).toEqual(vestingData.cliffDuration);
    expect(params.vestingTotalAmount).toEqual(vestingData.vestingTotalAmount);
    expect(params.vestingSenderAddress).toEqual(vestingData.vestingSenderAddress);
    expect(params.ownerAddress).toEqual(vestingData.ownerAddress);
}

get fun `test wallet vesting mainnet accepts plain internal transfer`() {
    val wallet = walletVesting();
    val sender = testing.treasury("wallet-vesting-mainnet-plain-transfer");
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

get fun `test wallet vesting mainnet rejects invalid external signed request`() {
    val wallet = walletVesting();
    val sender = testing.treasury("wallet-vesting-mainnet-external-gas");

    wallet.sendAny(
        sender.address,
        createEmptyCell(),
        { value: ton("0.05"), bounce: false },
    );

    val result = wallet.sendExternalWalletVestingSignedExternal(
        zeroSignature(),
        wallet.getSubwalletId(),
        (blockchain.now() + 1000) as uint32,
        wallet.seqno(),
        emptyOutgoingTail(),
    );

    expect(result).toBeNotAccepted();
    expect(result).toHaveExternalVmExitCode(Errors.InvalidSignature);
}
