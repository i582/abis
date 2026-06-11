import "@acton/build"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/fs"
import "@acton/io"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../wrappers/DedustVaultJettonV1.gen"

const FIXTURE_BOC_PATH = "data/dedust/v1/vault_jetton/testdata/DedustVaultJettonV1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xbf4cfd99b9b1e2bd17e001840dfd85706a9c781e75348a318f768c1ea2ae1a1b
const CURRENT_JETTON_VAULT_V2_CODE_HASH = 0xa30f0486b813dfe55f549fa986272349a96335e1e44e7276d4878c870083306f
const PINNED_MAINNET_BLOCK = 71185104

const LOCAL_CATALOG_JETTON_VAULT_CANDIDATE = "EQAf4BMoiqPf0U2ADoNiEatTemiw3UXkt5H90aQpeSKC2l7f"
const FACTORY_DERIVED_USDT_V1_VAULT_CANDIDATE = "EQBFzSwHFSBxzgaRzKQHqDii-seKmUJZi4UtzdK7xe72LQ_y"

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun catalogJettonVaultCandidate(): DedustVaultJettonV1 {
    return DedustVaultJettonV1.fromAddress(address(LOCAL_CATALOG_JETTON_VAULT_CANDIDATE));
}

get fun `test dedust jetton vault v1 code boc fixture is real and hash verified`() {
    val rawBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawBoc).toBeNotNull();
    expect(hasBocMagic(rawBoc!)).toBeTrue();

    val codeFromFixture = build("DedustVaultJettonV1", FIXTURE_BOC_PATH);
    val codeFromManifest = build("DedustVaultJettonV1");
    expect(codeFromFixture.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(EXPECTED_CODE_HASH);
    expect(codeFromManifest.hash()).toEqual(codeFromFixture.hash());

    println("DEDUST_JETTON_VAULT_V1_FIXTURE_CODE_HASH={}", codeFromFixture.hash());
}

get fun `test dedust jetton vault v1 live candidates do not provide active v1 storage`() {
    val catalogCandidate = catalogJettonVaultCandidate();
    val catalogAccount = testing.getAccountState(catalogCandidate.address);
    expect(catalogAccount).toBeNotNull();

    match (catalogAccount!.storage.state) {
        TlbAccountStateActive => {
            val code = catalogAccount!.storage.state.stateInit.code;
            expect(code).toBeNotNull();
            expect(code!.hash()).toEqual(CURRENT_JETTON_VAULT_V2_CODE_HASH);
            expect(code!.hash()).toNotEqual(EXPECTED_CODE_HASH);
        }
        TlbAccountStateUninit => {
            Assert.fail("Local catalog DeDust Jetton Vault candidate is uninitialized, expected upgraded V2 account");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Local catalog DeDust Jetton Vault candidate is frozen, expected upgraded V2 account");
        }
    }

    expect(scripts.isContractDeployed(address(FACTORY_DERIVED_USDT_V1_VAULT_CANDIDATE))).toBeFalse();

    println("DEDUST_JETTON_VAULT_V1_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
    println("DEDUST_JETTON_VAULT_V1_CATALOG_CANDIDATE_IS_V2={}", catalogCandidate.address);
    println("DEDUST_JETTON_VAULT_V1_FACTORY_DERIVED_USDT_CANDIDATE_UNINIT={}", FACTORY_DERIVED_USDT_V1_VAULT_CANDIDATE);
}
