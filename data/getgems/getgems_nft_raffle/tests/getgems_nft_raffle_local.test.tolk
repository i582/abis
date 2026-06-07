import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/getgems_nft_raffle.types"
import "../wrappers/GetgemsNftRaffle.gen"

const FIXTURE_BOC_PATH = "data/getgems/getgems_nft_raffle/testdata/GetgemsNftRaffle.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x4e8e3fc99d6c9b444df6c490521c8912fc772d6571b066ec61fe2ced1c7e6104
const ADD_COINS_VALUE = 50000000
const MIN_TONS_FOR_OPERATION = 10000000

struct GetgemsNftRaffleFixture {
    raffle: GetgemsNftRaffle
    leftUser: address
    rightUser: address
    superUser: address
}

fun hasBocMagic(mutate bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.loadUint(32) == EXPECTED_BOC_MAGIC;
}

fun getgemsNftRaffleStorage(
    leftUser: address,
    rightUser: address,
    superUser: address,
): GetgemsNftRaffleStorage {
    return GetgemsNftRaffleStorage {
        state: GetgemsNftRaffleStateData {
            state: 1,
            rightNftsCount: 1,
            rightNftsReceived: 0,
            leftNftsCount: 0,
            leftNftsReceived: 0,
        }.toCell(),
        addresses: GetgemsNftRaffleAddresses { leftUser, rightUser, superUser }.toCell(),
        commissions: GetgemsNftRaffleCommissions {
            leftCommission: 0,
            rightCommission: 0,
            leftCoinsGot: 0,
            rightCoinsGot: 0,
            nftTransferFee: 0,
        }.toCell(),
        dictionaries: GetgemsNftRaffleDictionaries {
            nfts: [],
            raffledNfts: [],
        }.toCell(),
    };
}

fun getgemsNftRaffleFixture(): GetgemsNftRaffleFixture {
    val left = testing.treasury("getgems-raffle-left");
    val right = testing.treasury("getgems-raffle-right");
    val superUser = testing.treasury("getgems-raffle-super");
    val storage = getgemsNftRaffleStorage(left.address, right.address, superUser.address);
    val stateInit = ContractState {
        code: build("GetgemsNftRaffle", FIXTURE_BOC_PATH),
        data: storage.toCell(),
    };
    val address = AutoDeployAddress { stateInit }.calculateAddress();
    val raffle = GetgemsNftRaffle { address, stateInit };
    return GetgemsNftRaffleFixture {
        raffle,
        leftUser: left.address,
        rightUser: right.address,
        superUser: superUser.address,
    };
}

fun deployGetgemsNftRaffleFixture(): GetgemsNftRaffleFixture {
    val fixture = getgemsNftRaffleFixture();
    if (fixture.raffle.stateInit == null) {
        Assert.fail("Getgems NFT raffle fixture has no state init");
    }

    val deployMsg = createMessage({
        bounce: false,
        value: ADD_COINS_VALUE,
        dest: { stateInit: fixture.raffle.stateInit },
        body: GetgemsNftRaffleAddCoins {},
    });
    val txs = net.send(fixture.leftUser, deployMsg);
    expect(txs).toHaveSuccessfulDeploy<GetgemsNftRaffleAddCoins>({
        from: fixture.leftUser,
        to: fixture.raffle.address,
        exitCode: 0,
    });
    expect(testing.isDeployed(fixture.raffle.address)).toBeTrue();
    return fixture;
}

fun loadGetgemsNftRaffleStorage(raffle: GetgemsNftRaffle): GetgemsNftRaffleStorage {
    val account = testing.getAccountState(raffle.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val code = accountState.stateInit.code;
            val data = accountState.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            return GetgemsNftRaffleStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Getgems NFT raffle local fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Getgems NFT raffle local fixture account is frozen");
        }
    }
}

get fun `test getgems nft raffle code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();

    var bytes = rawBoc!;
    expect(hasBocMagic(mutate bytes)).toBeTrue();

    var threeByteNull = beginCell().storeUint(0, 24).endCell().beginParse();
    expect(hasBocMagic(mutate threeByteNull)).toBeFalse();

    val code = build("GetgemsNftRaffle", FIXTURE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test getgems nft raffle local storage and getters`() {
    val fixture = deployGetgemsNftRaffleFixture();
    val storage = loadGetgemsNftRaffleStorage(fixture.raffle);
    val state = storage.state.load();
    val addresses = storage.addresses.load();
    val commissions = storage.commissions.load();
    val dictionaries = storage.dictionaries.load();
    val data = fixture.raffle.raffleState();

    expect(fixture.raffle.utilsCheckConditions()).toBeFalse();

    expect(state.state).toEqual(1);
    expect(state.rightNftsCount).toEqual(1);
    expect(state.rightNftsReceived).toEqual(0);
    expect(state.leftNftsCount).toEqual(0);
    expect(state.leftNftsReceived).toEqual(0);

    expect(addresses.leftUser).toEqual(fixture.leftUser);
    expect(addresses.rightUser).toEqual(fixture.rightUser);
    expect(addresses.superUser).toEqual(fixture.superUser);

    expect(commissions.leftCommission).toEqual(0);
    expect(commissions.rightCommission).toEqual(0);
    expect(commissions.leftCoinsGot).toEqual(ADD_COINS_VALUE - MIN_TONS_FOR_OPERATION);
    expect(commissions.rightCoinsGot).toEqual(0);
    expect(commissions.nftTransferFee).toEqual(0);
    expect(dictionaries.nfts).toBeEmpty();
    expect(dictionaries.raffledNfts).toBeEmpty();

    expect(data.state).toEqual(state.state);
    expect(data.rightNftsCount).toEqual(state.rightNftsCount);
    expect(data.rightNftsReceived).toEqual(state.rightNftsReceived);
    expect(data.leftNftsCount).toEqual(state.leftNftsCount);
    expect(data.leftNftsReceived).toEqual(state.leftNftsReceived);
    expect(data.leftUser).toEqual(addresses.leftUser);
    expect(data.rightUser).toEqual(addresses.rightUser);
    expect(data.superUser).toEqual(addresses.superUser);
    expect(data.leftCommission).toEqual(commissions.leftCommission);
    expect(data.rightCommission).toEqual(commissions.rightCommission);
    expect(data.leftCoinsGot).toEqual(commissions.leftCoinsGot);
    expect(data.rightCoinsGot).toEqual(commissions.rightCoinsGot);
    expect(data.nftTransferFee).toEqual(commissions.nftTransferFee);
    expect(data.nfts).toBeNull();
    expect(data.raffledNfts).toBeNull();

    println("GETGEMS_NFT_RAFFLE_LOCAL_ADDRESS={}", fixture.raffle.address);
    println("GETGEMS_NFT_RAFFLE_LOCAL_STORAGE={}", storage);
    println("GETGEMS_NFT_RAFFLE_LOCAL_STATE={}", data);
}
