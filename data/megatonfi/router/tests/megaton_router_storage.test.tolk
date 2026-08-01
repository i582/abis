import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/megaton_router.types"

const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const ROUTER_CODE_PATH = "data/megatonfi/router/testdata/MegatonRouter.boc"
const ROUTER_DATA_PATH = "data/megatonfi/router/testdata/MegatonRouter.data.boc"

fun loadRouterFixture(name: string, path: string): cell {
    val raw = fs.readBytes(path);
    expect(raw).toBeNotNull();
    val bytes = raw!;
    expect(bytes.preloadUint(32)).toEqual(EXPECTED_BOC_MAGIC);
    return build(name, path);
}

get fun `test megaton router parses exact mainnet storage fixture`() {
    // Toncenter snapshot at logical time 35750913000007.
    val code = loadRouterFixture("MegatonRouter", ROUTER_CODE_PATH);
    val data = loadRouterFixture("MegatonRouterData", ROUTER_DATA_PATH);
    val storage = MegatonRouterStorage.fromCell(data);

    expect(code.hash()).toEqual(0xcb97a903780dc5e37eab03de61f2dfce18f91db05c4ada8dd3f73f0c0fb3d862);
    expect(data.hash()).toEqual(0x6a242a06b0fc7b9d2963cb38fa38494916a6a88eab9dca31d9e1d416308ef690);
    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.adminAddress).toEqual(
        address("0:A8974CFB53CACBA4E676F675E2A9727A0012F1BD84633A576ED11EAD0009DCC4"),
    );
    expect(storage.poolFactoryAddress).toEqual(storage.adminAddress);
    expect(storage.rewardJettonMaster).toEqual(
        address("kQB-cCOQDwerEnUD4-6xoYD0eL6_yC1zogAvA5GuXTF0iImV"),
    );
    expect(storage.directTransferEnabled).toBeTrue();
    expect(storage.routedTransferTonAmount).toEqual(0);

    val roles = storage.roles.load();
    expect(roles.pendingAdminAddress).toBeNull();

    val mining = storage.mining.load();
    expect(mining.totalMiningAmount).toEqual(0);
    expect(mining.miningAmountPerSecond).toEqual(217013889);
    expect(mining.miningStartTime).toEqual(1677110400);
    expect(mining.miningHalfLife).toEqual(124416000);
    expect(mining.poolCount).toEqual(26);
    expect(mining.distributedRewardAmount).toEqual(0);
}
