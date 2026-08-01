import "@acton/build"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/megaton_exchange.types"
import "../wrappers/MegatonExchange.gen"

const EXCHANGE_ADDRESS = "EQCocXc3t9WDrQ2gnq6kD3gJ7ENvA-LJ9PmFhSGX_pG3gHtO"
const WALLET_OWNER_ADDRESS = "0:84E9070FC38C31FDD1B9AB7BA80834959AF44E86C74F921831440024F35CB6AF"
const EXPECTED_OWNER_WALLET = "EQDQqI4ZKdAJQKSudY5PK9iVXjGus_wVBlZaAQ-HAG-vBS36"
const EXPECTED_CODE_HASH = 0x0045aba569e0fd4e4124b3d5162764038dc0c0c5e849d32ebee585471d085c7c
const EXPECTED_DATA_HASH = 0x775a6103cfe0838f2fe95a9dc4123f7343dbd269476e05870e126c0770cc76b8
const PINNED_MAINNET_BLOCK = 83400134

fun exchange(): MegatonExchange {
    return MegatonExchange.fromAddress(address(EXCHANGE_ADDRESS));
}

fun loadExchangeStorage(contract: MegatonExchange): MegatonExchangeStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return MegatonExchangeStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Megaton Exchange is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Megaton Exchange is frozen at the pinned block");
        }
    }
}

get fun `test megaton exchange is deployed with the exact fixture code`() {
    val contract = exchange();
    val storage = loadExchangeStorage(contract);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(
        build("MegatonExchange", "data/megatonfi/exchange/testdata/MegatonExchange.boc").hash(),
    ).toEqual(
        EXPECTED_CODE_HASH,
    );
    expect(storage.totalSupply).toEqual(20357994158989032692);
}

get fun `test megaton exchange storage agrees with all four public getters`() {
    val contract = exchange();
    val storage = loadExchangeStorage(contract);
    val pool = storage.poolState.load();
    val masters = pool.tokenMasters.load();
    val wallets = pool.tokenWallets.load();
    val miningSchedule = pool.miningSchedule.load();
    val miningState = pool.miningState.load();
    val jettonData = contract.getJettonData();
    val swapData = contract.getLpSwapData();
    val miningData = contract.getLpMiningData();
    val walletAddress = contract.getWalletAddress(address(WALLET_OWNER_ADDRESS));

    expect(jettonData.totalSupply).toEqual(storage.totalSupply);
    expect(jettonData.mintable).toBeTrue();
    expect(jettonData.adminAddress).toEqual(storage.adminAddress);
    expect(jettonData.content.hash()).toEqual(storage.content.hash());
    expect(jettonData.walletCode.hash()).toEqual(storage.walletCode.hash());

    expect(swapData.swapFee).toEqual(storage.swapFee);
    expect(swapData.minimumLpAmount).toEqual(storage.minimumLpAmount);
    expect(swapData.routerAddress).toEqual(storage.routerAddress);
    expect(swapData.tokenAMasterAddress).toEqual(masters.tokenA);
    expect(swapData.tokenAWalletAddress).toEqual(wallets.tokenA);
    expect(swapData.tokenABalance).toEqual(pool.tokenABalance);
    expect(swapData.tokenAPendingBalance).toEqual(pool.tokenAPendingBalance);
    expect(swapData.tokenBMasterAddress).toEqual(masters.tokenB);
    expect(swapData.tokenBWalletAddress).toEqual(wallets.tokenB);
    expect(swapData.tokenBBalance).toEqual(pool.tokenBBalance);
    expect(swapData.tokenBPendingBalance).toEqual(pool.tokenBPendingBalance);

    expect(miningData.miningAmount).toEqual(miningSchedule.miningAmount);
    expect(miningData.datetimeAmount).toEqual(miningSchedule.datetimeAmount);
    expect(miningData.minableTime).toEqual(miningSchedule.minableTime);
    expect(miningData.halfLife).toEqual(miningSchedule.halfLife);
    expect(miningData.lastIndex).toEqual(miningState.lastIndex);
    expect(miningData.lastMined).toEqual(miningState.lastMined);
    expect(miningData.miningRateCell.hash()).toEqual(miningState.miningRateCell.hash());
    expect(walletAddress).toEqual(address(EXPECTED_OWNER_WALLET));

    println("MEGATON_EXCHANGE_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
