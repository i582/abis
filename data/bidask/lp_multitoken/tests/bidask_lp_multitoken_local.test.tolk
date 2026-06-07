import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/bidask_lp_multitoken.types"
import "../wrappers/BidaskLpMultitoken.gen"

const FIXTURE_BOC_PATH = "data/bidask/lp_multitoken/testdata/BidaskLpMultitoken.boc"
const DATA_FIXTURE_BOC_PATH = "data/bidask/lp_multitoken/testdata/BidaskLpMultitoken.data.boc"
const DATA_FIXTURE_BOC = "te6ccgEBAQEASQAAjYAa3cmmSJ1B1+T6VKUXCSsfLKLEU0TQnFxIktib6b633zAATp5QvI/PB6eqvx0JvZNC7j8PDN8mP4EFXcZ5ftNsmTgAAAAB"
const NONEMPTY_DATA_FIXTURE_BOC = "te6ccgECDAEAA1UAAY2AGt3JpkidQdfk+lSlFwkrHyyixFNE0JxcSJLYm+m+t98wA1knh15iDmkxZfFc+Y5tPq8TfA0/GwR+x/onehMoTOgAAAAAYwECCZwAAACoAgMCAVgEBQIBSAgJAPVQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACFH/omUaCFG4nP0hfU4X7N7gCASAGBwD1AAAAAAAAAAAAAAAAAACEdtg+dC5p4pUp+tgJikCB6AAAAAAAAAAAAAAAAAAIPOjTeumdyAptz4kUJMQMbcAAAAAAAAAAAAAAAAAAgycYAQD4ufIU9FYkePhoalwAAAAAAAAAAAAAAAAACCgHeKxjgFaJDvD3PwiFR8cgAPUAAAAAAAAAAAAAAAAAAIHaqsayY0D50tiSHwrIUxxYAAAAAAAAAAAAAAAAAAgTWwp9Dt9iWhPc1mHk83/2gAAAAAAAAAAAAAAAAACAkYgigv9ra/G1edzVcrKbzAAAAAAAAAAAAAAAAAAH/uMCx9wIQvZVkSVeY/OaAiACASAKCwD1QAAAAAAAAAAAAAAAAACPfNqEphWeaBwBJp21F5H7kQAAAAAAAAAAAAAAAAAJA0D5wVETZLFR4VCrqLC+0zAAAAAAAAAAAAAAAAAAkOwun5ND6jsSC2cAkIDEEPoAAAAAAAAAAAAAAAAACRpTi5zZkQb6xeYg1lXlsjS4APUAAAAAAAAAAAAAAAAAAH9Lp7zIq8gj57Y2wUz/gK/8AAAAAAAAAAAAAAAAAAfO9urqMGPOD9e+kAG/sPmPgAAAAAAAAAAAAAAAAAItEi7lP0MI/K40o1mLM3uW8AAAAAAAAAAAAAAAAAAi/ZddhRMDTyBEsY9CL85hfqAA9QAAAAAAAAAAAAAAAAACMqRI9uZLYq1JjDRX4RK3qegAAAAAAAAAAAAAAAAAI1cqzIj3CwWtZBm8NgxxwmaAAAAAAAAAAAAAAAAAAjhEpdqmCZRNvXuvvyhxn+UIAAAAAAAAAAAAAAAAACOxo4wFNvQXp3HmyuSrSeqSoA=="
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xa2ce96a1b2e4985d9070c0bc05b97d3e5cc56edb83f4e15b052a60f0ed235a54
const EXPECTED_EMPTY_DATA_HASH = 0x13e2d5ba53062aea740420120a6b04b7d7ecf30857a0436a030891480e0e92bf
const EXPECTED_NONEMPTY_DATA_HASH = 0xf8663cef06d8ce58e4a9caa079f912a7ea7b0ab57779575e744444077930962c

const MAINNET_BIDASK_LP_MULTITOKEN_EMPTY_ADDRESS = "EQDW-sWKZPwoMucVoSKSIproQoVWG4aEy-Bvtbk8cDmuvAFw"
const MAINNET_BIDASK_LP_MULTITOKEN_NONEMPTY_ADDRESS = "EQDWhSlpMSzLsCBhYLLwbZYEE2Z3Jbj4QreGcR2Hhf9O_0H_"
const EXPECTED_RANGE_ADDRESS = "0:D6EE4D3244EA0EBF27D2A528B84958F96516229A2684E2E24496C4DF4DF5BEF9"
const EXPECTED_EMPTY_USER_ADDRESS = "0:13A7942F23F3C1E9EAAFC7426F64D0BB8FC3C337C98FE04157719E5FB4DB264E"
const EXPECTED_NONEMPTY_USER_ADDRESS = "0:D649E1D798839A4C597C573E639B4FABC4DF034FC6C11FB1FE89DE84CA133A00"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun compileBidaskLpMultitokenGetterSurface(wallet: BidaskLpMultitoken): void {
    val tokens: cell? = wallet.getTokens();
    val authority: any_address = wallet.getAuthorityAddress();
    val nftData: BidaskLpMultitokenNftDataReply = wallet.getNftData();
    val revokedTime: int = wallet.getRevokedTime();
    val binBalance: int = wallet.getBin(0);
    val binsNumber: int = wallet.getBinsNumber();
    val rawStorage: cell = wallet.getStorage();
}

fun expectChunk166(chunk: BidaskLpMultitokenTokenChunk): void {
    var bits = chunk as slice;
    expect(bits.remainingBitsCount()).toEqual(976);
    expect(bits.remainingRefsCount()).toEqual(0);
    expect(bits.loadUint(244)).toEqual(11268811034975541842165836454819179536506);
    expect(bits.loadUint(244)).toEqual(11212886069249382762565930415004369039799);
    expect(bits.loadUint(244)).toEqual(11157238648490635487292907381009088649879);
    expect(bits.loadUint(244)).toEqual(11101867395296418576797950905944919842588);
    expect(bits.remainingBitsCount()).toEqual(0);
    expect(bits.remainingRefsCount()).toEqual(0);
}

get fun `test bidask lp multitoken code and data boc fixtures are real`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();

    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();

    val codeFromFixture = build("BidaskLpMultitoken", FIXTURE_BOC_PATH);
    val codeFromManifest = build("BidaskLpMultitoken");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());
}

get fun `test bidask lp multitoken parses saved empty storage data fixture`() {
    val dataCell = parseCellFromBase64(DATA_FIXTURE_BOC);
    val storage = BidaskLpMultitokenStorage.fromCell(dataCell);
    val contract = BidaskLpMultitoken.fromStorage(storage);

    expect(dataCell.hash()).toEqual(EXPECTED_EMPTY_DATA_HASH);
    expect(storage.rangeAddress).toEqual(address(EXPECTED_RANGE_ADDRESS));
    expect(storage.userAddress).toEqual(address(EXPECTED_EMPTY_USER_ADDRESS));
    expect(storage.binsNumber).toEqual(0);
    expect(storage.tokenChunks).toBeNull();

    expect(contract.stateInit).toBeNotNull();
    expect(contract.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(contract.stateInit!.data.hash()).toEqual(dataCell.hash());
}

get fun `test bidask lp multitoken parses saved nonempty storage token dictionary`() {
    val dataCell = parseCellFromBase64(NONEMPTY_DATA_FIXTURE_BOC);
    val storage = BidaskLpMultitokenStorage.fromCell(dataCell);
    val tokenChunksCell = storage.tokenChunks;
    expect(tokenChunksCell).toBeNotNull();

    val tokenChunks = createMapFromLowLevelDict<int32, BidaskLpMultitokenTokenChunk>(
        tokenChunksCell,
    );
    var firstGroup = tokenChunks.mustGet(165) as slice;
    val secondGroup = tokenChunks.mustGet(166);
    val lastGroup = tokenChunks.mustGet(170) as slice;

    expect(dataCell.hash()).toEqual(EXPECTED_NONEMPTY_DATA_HASH);
    expect(storage.rangeAddress).toEqual(address(EXPECTED_RANGE_ADDRESS));
    expect(storage.userAddress).toEqual(address(EXPECTED_NONEMPTY_USER_ADDRESS));
    expect(storage.binsNumber).toEqual(24);
    expect(tokenChunks).toHaveLength(6);
    expect(tokenChunks).toContainKey(165);
    expect(tokenChunks).toContainKey(170);

    expect(firstGroup.remainingBitsCount()).toEqual(976);
    expect(firstGroup.loadUint(244)).toEqual(0);
    expect(firstGroup.loadUint(244)).toEqual(0);
    expect(firstGroup.loadUint(244)).toEqual(0);
    expect(firstGroup.loadUint(244)).toBeGreater(0);
    expectChunk166(secondGroup);
    expect(lastGroup.remainingBitsCount()).toEqual(976);
    expect(lastGroup.remainingRefsCount()).toEqual(0);
}

get fun `test bidask lp multitoken generated wrapper local surface`() {
    val dataCell = parseCellFromBase64(DATA_FIXTURE_BOC);
    val storage = BidaskLpMultitokenStorage.fromCell(dataCell);
    val fromStorage = BidaskLpMultitoken.fromStorage(storage);
    val emptyMainnet = BidaskLpMultitoken.fromAddress(
        address(MAINNET_BIDASK_LP_MULTITOKEN_EMPTY_ADDRESS),
    );
    val nonemptyMainnet = BidaskLpMultitoken.fromAddress(
        address(MAINNET_BIDASK_LP_MULTITOKEN_NONEMPTY_ADDRESS),
    );

    expect(fromStorage.stateInit).toBeNotNull();
    expect(fromStorage.stateInit!.code.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(fromStorage.stateInit!.data.hash()).toEqual(dataCell.hash());
    expect(emptyMainnet.address).toEqual(address(MAINNET_BIDASK_LP_MULTITOKEN_EMPTY_ADDRESS));
    expect(emptyMainnet.stateInit).toBeNull();
    expect(nonemptyMainnet.address).toEqual(address(MAINNET_BIDASK_LP_MULTITOKEN_NONEMPTY_ADDRESS));
    expect(nonemptyMainnet.stateInit).toBeNull();

    println("BIDASK_LP_MULTITOKEN_EMPTY_ADDRESS={}", emptyMainnet.address);
    println("BIDASK_LP_MULTITOKEN_NONEMPTY_ADDRESS={}", nonemptyMainnet.address);
}
