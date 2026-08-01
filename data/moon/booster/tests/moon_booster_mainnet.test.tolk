import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/moon_booster.types"
import "../wrappers/MoonBooster.gen"

const BOOSTER_ADDRESS = "EQAyAz5tgCe2HVeJnYG9WN_sJ9ozkfAJEomnGTRpqMuOOeOv"
const ADMIN_ADDRESS = "EQDG2aXRvu7qflZ1EK0wkgXL0iQeJthQqgRIZ2p01L8hKSGm"
const RESPONSE_DESTINATION = "EQB_gN-HihFy9doIWc742xj7kHveXb8bPZFoEuJX3Iby7gt1"
const POOL_ADDRESS = "EQCMpWCnDHVhMnUspAaKxagkXuW0NGhMq6Y-HCW_BO20e-Ju"
const BOOSTER_JETTON_WALLET = "EQChAbocvs3QWIOnmih4-hb6q19u_4orDE5GCeXUDLWS55CM"
const FIXTURE_BOC_PATH = "data/moon/booster/testdata/MoonBooster.boc"
const DATA_FIXTURE_BOC_PATH = "data/moon/booster/testdata/MoonBooster.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xce84c382c8b6ac0d05212bbaa34d05e54e1e30e2cc9289f2d9c9d64726a112a8
const EXPECTED_DATA_HASH = 0x43a604f3f3f72051e25b78824784425f5c912849c74eb1c21c6d0b11e069a6b0
const PINNED_MAINNET_BLOCK = 47400261

fun booster(): MoonBooster {
    return MoonBooster.fromAddress(address(BOOSTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadBoosterStorage(contract: MoonBooster): MoonBoosterStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("MoonBooster", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            expect(data!.hash()).toEqual(build("MoonBooster", DATA_FIXTURE_BOC_PATH).hash());
            return MoonBoosterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Moon Booster is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Moon Booster is frozen at the pinned block");
        }
    }
}

get fun `test moon booster code and data fixtures match mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(build("MoonBooster", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("MoonBooster", DATA_FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test moon booster parses pinned storage and getters`() {
    val contract = booster();
    val storage = loadBoosterStorage(contract);
    val boost = storage.boost.load();
    val getterStorage = MoonBoosterStorage.fromCell(contract.getBooster());
    val getterBoost = MoonBoosterBoostData.fromCell(contract.getBoostData());

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.status).toEqual(1);
    expect(storage.boosterId).toEqual(13);
    expect(storage.admin).toBeNotNull();
    expect(storage.admin!).toEqual(address(ADMIN_ADDRESS));
    expect(storage.responseDestination).toBeNotNull();
    expect(storage.responseDestination!).toEqual(address(RESPONSE_DESTINATION));
    expect(storage.pool).toBeNotNull();
    expect(storage.pool!).toEqual(address(POOL_ADDRESS));
    expect(boost.amountPerRound).toEqual(1000000);
    expect(boost.startTime).toEqual(1745957374);
    expect(boost.currentRound).toEqual(3);
    expect(boost.roundInterval).toEqual(86400);
    expect(boost.roundCount).toEqual(5);
    expect(boost.jettonWallet).toBeNotNull();
    expect(boost.jettonWallet!).toEqual(address(BOOSTER_JETTON_WALLET));

    expect(contract.getStatus()).toEqual(storage.status);
    expect(contract.getPool().castToInternal()).toEqual(address(POOL_ADDRESS));
    expect(getterStorage.toCell().hash()).toEqual(storage.toCell().hash());
    expect(getterBoost.toCell().hash()).toEqual(boost.toCell().hash());
    println("MOON_BOOSTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println(
        "MOON_BOOSTER_ID={} STATUS={} ROUND={}/{}",
        storage.boosterId,
        storage.status,
        boost.currentRound,
        boost.roundCount,
    );
    println(
        "MOON_BOOSTER_AMOUNT={} PERIOD={}",
        boost.amountPerRound,
        boost.roundInterval,
    );
}

get fun `test moon booster rejects unauthorized close through wrapper`() {
    val contract = booster();
    val sender = testing.treasury("moon-booster-unauthorized-close");
    val statusBefore = contract.getStatus();

    val txs = contract.sendMoonBoosterCloseExpired(
        sender.address,
        1,
        { value: ton("0.05"), bounce: false },
    );

    expect(txs).toHaveFailedTx<MoonBoosterCloseExpired>({
        from: sender.address,
        to: contract.address,
        exitCode: MoonBoosterErrors.UnauthorizedSender,
    });
    expect(contract.getStatus()).toEqual(statusBefore);
}
