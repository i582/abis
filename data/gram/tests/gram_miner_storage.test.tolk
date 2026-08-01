import "@acton/build"
import "@acton/fs"
import "@acton/testing/expect"
import "../types/gram_miner.types"

const CODE_BOC_PATH = "data/gram/testdata/GramMiner.boc"
const DATA_BOC_PATH = "data/gram/testdata/GramMiner.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xccae6ffb603c7d3e779ab59ec267ffc22dc1ebe0af9839902289a7a83e4c00f1
const EXPECTED_DATA_HASH = 0x679a7033ab9b849b3b945682adb1afc6175cecc353ef1ca02f8e42485abf6058
const EXPECTED_JETTON_WALLET = "0:64ED4B1363ADE3128DF98E5A9AD2C1EF4B949E7063AA57DB2FCAA6581915061F"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test gram miner code and data fixtures are real bocs`() {
    val rawCode = fs.readBytes(CODE_BOC_PATH);
    val rawData = fs.readBytes(DATA_BOC_PATH);
    expect(rawCode).toBeNotNull();
    expect(rawData).toBeNotNull();
    expect(hasBocMagic(rawCode!)).toBeTrue();
    expect(hasBocMagic(rawData!)).toBeTrue();

    expect(build("GramMiner", CODE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
    expect(build("GramMinerData", DATA_BOC_PATH).hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test gram miner parses saved mainnet storage`() {
    val data = build("GramMinerData", DATA_BOC_PATH);
    val storage = GramMinerStorage.fromCell(data);
    val parameters = storage.parameters.load();

    expect(storage.toCell().hash()).toEqual(data.hash());
    expect(storage.seqno).toEqual(3);
    expect(storage.subwalletId).toEqual(0);
    expect(storage.publicKey).toEqual(
        0x0892c0ecdfde9feb99cfbbbc06cfb7250cf326b1449d01dfbc54baa41de395f9,
    );
    expect(storage.seed).toEqual(0x03a39ed130df9426ba6697a6d24a1c99);
    expect(storage.powComplexity).toEqual(
        0x0400000000000000000000000000000000000000000000000000000000000000,
    );
    expect(storage.lastSuccess).toEqual(1705950821);
    expect(parameters.rewardAmount).toEqual(123000000000);
    expect(parameters.targetDelta).toEqual(100000);
    expect(parameters.minComplexityExponent).toEqual(200);
    expect(parameters.maxComplexityExponent).toEqual(250);
    expect(parameters.jettonWalletAddress.castToInternal()).toEqual(
        address(EXPECTED_JETTON_WALLET),
    );
}
