import "@acton/build"
import "@acton/fmt"
import "@acton/testing/expect"
import "../types/dedust_v2_cpmm.types"

const EXPECTED_CODE_HASH = 0x5851780d2386e989b9ab956da7cec5c69a667b9e525f628dcba5eb02c1ee0367
const CODE_BOC_PATH = "data/dedust/cpmm_v2/testdata/DedustV2Cpmm.boc"
const DATA_BOC_BASE64 = "te6ccgECCgEAAY0AAy9bgRZ5iL/8WTAJMvUX4GQCDuBMScpKCMABAgMCjyAB0c2lR6nbkJ5ApuKB/dvRAAsWDZloRHQcbaEVM2BGDVQA7uAIk//ySrqk9GZ43tEaFyEDD3I+LiBmGZnt1CuIRZQAZBOIlgQFAC1QzoqEowAAcF7vmU5TDbcFYZ51OZggIAJDgAZsyfMCfBf7JtYmZmxd63Ulv4FsArI0rBFdGa3wtgHWmggJAEUCgAdHNpUep25CeQKbigf3b0QALFg2ZaER0HG2hFTNgRg1UAIBSAYHAE0gAdHNpUep25CeQKbigf3b0QALFg2ZaER0HG2hFTNgRg1QAACTqAQACwAAASdQCACFoAdHNpUep25CeQKbigf3b0QALFg2ZaER0HG2hFTNgRg1UAPS4QN/Df9+0rkLLAcLlWBUmig1E5vQoZqYvbHwCBY1KgCFoB6XCBv4b/v2lchZYDhcqwKk0UGonN6FDNTF7Y+AQLGpUADo5tKj1O3ITyBTcUD+7eiABYsGzLQiOg420IqZsCMGqg=="

get fun `test dedust v2 cpmm code fixture hash matches live address`() {
    val code = build("DedustV2Cpmm", CODE_BOC_PATH);
    expect(code.hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test dedust v2 cpmm storage parses saved mainnet data cell`() {
    val data = parseCellFromBase64(DATA_BOC_BASE64);
    val storage = DedustV2CpmmStorage.fromCell(data);

    expect(storage.walletRegistryState.hash()).toBeGreater(0);
    expect(storage.feeState.hash()).toBeGreater(0);
    expect(storage.assetState.hash()).toBeGreater(0);
    expect(storage.rootDictionary).toBeNull();
    expect(storage.depositActive).toBeTrue();
    expect(storage.swapActive).toBeTrue();
    expect(storage.liquidity).toEqual(612372435695794);
    expect(storage.reserveX).toEqual(1264308124684);
    expect(storage.reserveY).toEqual(296604912019870737);

    match (storage.mode) {
        DedustV2CpmmModeIdle => {
            expect(false).toBeTrue();
        }
        DedustV2CpmmModeWithAddress => {
            expect(false).toBeTrue();
        }
        DedustV2CpmmModeSettled => {}
    }
}
