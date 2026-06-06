import "@acton/fmt"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/expect"
import "../types/ts_ton_minter.types"

const CODE_FIXTURE_BOC_PATH = "data/tonstakers/ts_ton_minter/testdata/TsTonMinter.boc"
const DATA_FIXTURE_BOC_PATH = "data/tonstakers/ts_ton_minter/testdata/TsTonMinter.data.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_DATA_HASH = 0x161114ef788fa7c7feccaaaf9d650266118d78b7db742a59985b4a06e0ddb0ab
const EXPECTED_POOL_ADMIN = "0:A45B17F28409229B78360E3290420F13E4FE20F90D7E2BF8C4AC6703259E22FA"
const DATA_FIXTURE_BOC =
    "te6ccgECKAEABYsAAmOAEb4ZliDWNTgBSLYv5QgSRTbwbBxlIIQeJ8n8QfIa/FfxiVjOBks8RfQAAAAAAAAAAQECAQMAwAMBFP8A9KQT9LzyyAsOAgEgBAUBQ7/4cuvbUU2cl8KDt/CuUXkCnithGcOUYnGeT0btj3QT5kAGAgEgBwgAUABodHRwczovL3RvbnN0YWtlcnMuY29tL2pldHRvbi9tZXRhLmpzb24CASAJCgFCv66A/S8eA0gOIoI2NZbudS17sn9Qd2uVCGoCeRiWdZI+DQFBv0VGpv/ht5z92GutPbh0MT3N4vsF5qdKp/NVLZYXx50TCwFBv27U+UKnhIziywZrd6ESjGof+MQ/Q4otziRhK6n/q4sDDAAeAFRvbnN0YWtlcnMgVE9OAAwAdHNUT04ABAA5AgFiDxACAsoREgIBICUmApfUB0NMDAXGwkl8E4PpAMAHTHwEB0z8BIoIQGC2N3bqeMjMz8CP4QscF8uD08Cbg8CQighBu2xiJuuMCMTQxghBmFzpFuuMCW4QP8vCExQCAWIfIAR0MvpA+EKII1lwVHAAJBA1EEcQNlnIUAb6AlAEzxZYzxbMAfoCAQHLL8kiyMsBEvQA9ADLAMnbPPgoiCccFRYA8Pgj+ES88uD2+Eny0Pht+EXAAJ8w+EbQ+gD0BDBSIr7y4Pfe+EXAAZwwggl9eEC+8uD3+EaRMeLIgBABywX4Qs8WcPoCcAHLaoIQTw91EAHLH1gByz/4QwHLP/hEAcsv+EUByz/4R/oC+Ej6AvQAf/hp8CXJgED7AAEU/wD0pBP0vPLICxcD3gJwAshYzxYBzxZw+gJw+gLJIcjLARP0ABL0AMsAyds8FMcF8uD1+CP4RLny4PkC0y8BgQ8y+EQSvvL0+gDSAAEB0gABAdEBlvhHWKD4Z5b4SFig+GjiBIIJycOABKETtglw+wIC4w/wJcmBAIL7ABwdHgIBYhgZAULQMzHQ0wMBcbCRW+D6QDAB0x8BghAr1jcEuuMCW4QP8vAaAB2hcZfaiaH0gfSB9AH0AGEB/u1E0PpA+kD6APoAMFI2xwXy4fQD0z8BAfpA0y8BAfoA0gABAdIAATFRKKEpoSGTUYiglVGZoAkI4ijC//Lh9YIImJaAcPsCJhA4QBrIUATPFljPFgH6AgH6AsntVMiAEAHLBVAEzxZw+gJwActqghBu2xiJAcsfWAHLPwHPFgEbACYByy9Y+gJYAcoAAQHKAMmDBvsAABz5AHTIywJwAcoHy//J0ABKyIAYAcsF+ELPFnD6AnABy2qCCiL9ywHLHwEByz/4QwHLPwHPFgA6yIAQAcsFWM8WcPoCcAHLaoIQ1TJ22wHLHwEByz8AMfdqJoaQAA/DD8IPloef0gAPwxaZ+AmPwxwCASAhIgIBICMkALdNMvAfhk0z8B+GXUAfhm+kAw+Gp/+GFw+Gdw+Ghw+GnwJYIJycOAcPsCyIAYAcsF+ELPFnD6AnABy2qCEI4quyMByx8BAcs/+EMByz/4RAHLL/hKzxbJgQCC+wCAB3O1E0NIAAfhhgQ8x+EHy9PpAAfhi0z8B+GPTLwH4ZNM/Afhl1AH4ZvoAAfhn+gAB+GjSAAH4afpAMPhqgAGE+EbI+EEBygD4Qs8W+EMByz/4RAHLL/hFAcs/zPhH+gL4SPoC+EkBygD4Ss8Wye1UgAI+9ul9qJ2ovajya34Efaz9rL2skl4Enag9viA+X/8I2h9AHoCfCD8JPwhfCV8IfwifCL8I/wkCEWIPQg0iCwII4gbCBKIEggRwBY7/GJ2onai9qPJrfgR9rP2svaySXgSdqD2+ID5f/wg/CF8IfwifCL8I0R8I/wkfCT8JUJwhCAhK+uw3I4gK34m9yHiVH4Wu5667JNPZX0Z8i521ivsh4"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun dataFixtureCell(): cell {
    return parseCellFromBase64(DATA_FIXTURE_BOC);
}

get fun `test tsTON minter code and data fixtures are real BoCs`() {
    val rawCodeBoc = fs.readBytes(CODE_FIXTURE_BOC_PATH);
    val rawDataBoc = fs.readBytes(DATA_FIXTURE_BOC_PATH);

    expect(rawCodeBoc).toBeNotNull();
    expect(rawDataBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(hasBocMagic(rawDataBoc!)).toBeTrue();
    expect(dataFixtureCell().hash()).toEqual(EXPECTED_DATA_HASH);
}

get fun `test tsTON minter saved data fixture parses storage`() {
    val data = dataFixtureCell();
    val storage = TsTonMinterStorage.fromCell(data);

    expect(data.hash()).toEqual(EXPECTED_DATA_HASH);
    expect(storage.totalSupply).toBeGreater(0);
    expect(storage.adminAddress).toEqual(address(EXPECTED_POOL_ADMIN));
    expect(storage.jettonContent.hash()).toBeGreater(0);
    expect(storage.votingId).toBeGreaterOrEqual(0);
    expect(storage.votingCode.hash()).toBeGreater(0);

    println("TSTON_MINTER_STORAGE_FIXTURE={}", storage);
    println("TSTON_MINTER_STORAGE_CONTENT_HASH={}", storage.jettonContent.hash());
    println("TSTON_MINTER_STORAGE_VOTING_CODE_HASH={}", storage.votingCode.hash());
}
