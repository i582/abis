import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/verifier_registry.types"
import "../wrappers/VerifierRegistry.gen"

const FIXTURE_BOC_PATH = "data/verifier/verifier_registry/testdata/VerifierRegistry.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0xac498fc3c594b302d0e3ea812971e070d7e5376e0e7031d9f3663c42d3f0a687
const EXPECTED_DATA_HASH = 0x11bfda22c14f2753177a4e62647e0d9cd7523212c191144262d497a6a19875ca
const PINNED_MAINNET_BLOCK = 83374126
const REGISTRY_ADDRESS = "EQDn0lCfJbUPhD6ST-Lwh8bj-9xcc24_G_C1QAk6uBAfaeMN"
const ORBS_ADMIN_ADDRESS = "0:81ad175ac152f1ebacb63bba983eaac599df635020db47c6d78c2e26d52ca6c2"
const ORBS_ID = 0x6aaf20fed58ba5e6db692909e78e5c5c6525e28d1cfa8bd22dc216729b4841b3
const VERIFIER_TON_ORG_ID = 0x7494b4c0aca9820e02a5024a9009a84321bd379467c8be09c9d25a26f18d0b87

fun registry(): VerifierRegistry {
    return VerifierRegistry.fromAddress(address(REGISTRY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadRegistryStorage(contract: VerifierRegistry): VerifierRegistryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("VerifierRegistry", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return VerifierRegistryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Verifier Registry is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Verifier Registry is frozen at the pinned block");
        }
    }
}

get fun `test verifier registry code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("VerifierRegistry", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test verifier registry parses full storage and individual getters`() {
    val contract = registry();
    val storage = loadRegistryStorage(contract);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.verifiersNum).toEqual(2);
    expect(storage.verifiers.isEmpty()).toBeFalse();

    val storedOrbsLookup = storage.verifiers.get(ORBS_ID);
    expect(storedOrbsLookup.isFound).toBeTrue();
    val storedOrbs = storedOrbsLookup.loadValue();
    expect(storedOrbs.admin).toEqual(address(ORBS_ADMIN_ADDRESS));
    expect(storedOrbs.settings.multiSigThreshold).toEqual(2);
    expect(storedOrbs.settings.pubKeyEndpoints.isEmpty()).toBeFalse();

    expect(contract.getVerifiersNum()).toEqual(storage.verifiersNum);
    val orbs = contract.getVerifier(ORBS_ID);
    expect(orbs.found).toBeTrue();
    expect(orbs.admin.castToInternal()).toEqual(address(ORBS_ADMIN_ADDRESS));
    val orbsSettings = orbs.settings.load();
    expect(orbsSettings.multiSigThreshold).toEqual(2);
    expect(orbsSettings.pubKeyEndpoints.isEmpty()).toBeFalse();

    val missing = contract.getVerifier(0);
    expect(missing.found).toBeFalse();
    println("VERIFIER_REGISTRY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}

get fun `test verifier registry decodes typed get verifiers cell`() {
    val contract = registry();
    val verifiersSlice = contract.getVerifiers();
    val result = VerifierRegistryVerifiersMap.fromSlice(verifiersSlice);

    expect(result.verifiers.isEmpty()).toBeFalse();
    val orbsLookup = result.verifiers.get(ORBS_ID);
    expect(orbsLookup.isFound).toBeTrue();
    expect(orbsLookup.loadValue().settings.multiSigThreshold).toEqual(2);

    val tonOrgLookup = result.verifiers.get(VERIFIER_TON_ORG_ID);
    expect(tonOrgLookup.isFound).toBeTrue();
    expect(tonOrgLookup.loadValue().settings.multiSigThreshold).toEqual(1);
}
