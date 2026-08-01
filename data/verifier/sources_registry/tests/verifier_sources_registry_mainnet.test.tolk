import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/verifier_sources_registry.types"
import "../wrappers/VerifierSourcesRegistry.gen"

const FIXTURE_BOC_PATH = "data/verifier/sources_registry/testdata/VerifierSourcesRegistry.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x148ab33241d58ed70920f3c9b924d97fe9948e9b6f320a9904d65b2da169895d
const EXPECTED_DATA_HASH = 0x510e07f276cc753282adbe836305f728e7a3beae164c9c6676dff6c7e5001ffe
const EXPECTED_SOURCE_ITEM_CODE_HASH = 0x5459cb725307a812e6534a2f15b4f06701d2ae6726999f6d513f5747917d325a
const PINNED_MAINNET_BLOCK = 83374126
const REGISTRY_ADDRESS = "EQD-BJSVUJviud_Qv7Ymfd3qzXdrmV525e3YDzWQoHIAiInL"
const ADMIN_ADDRESS = "0:81ad175ac152f1ebacb63bba983eaac599df635020db47c6d78c2e26d52ca6c2"
const VERIFIER_REGISTRY_ADDRESS = "0:e7d2509f25b50f843e924fe2f087c6e3fbdc5c736e3f1bf0b540093ab8101f69"
const SOURCE_ITEM_ADDRESS = "0:07eb6ed3a130ef7e48e1ca1029a0bd9987d9bc84acedad79e260a7afa168a0b0"
const VERIFIER_TON_ORG_ID = 0x7494b4c0aca9820e02a5024a9009a84321bd379467c8be09c9d25a26f18d0b87
const VERIFIED_CODE_HASH = 0x88db7990749293ec0493a9b04ea5b65203e7152783a0c9702e89b950c28a4fca

fun registry(): VerifierSourcesRegistry {
    return VerifierSourcesRegistry.fromAddress(address(REGISTRY_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    if (bytes.remainingBitsCount() < 32) {
        return false;
    }
    return bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadRegistryStorage(contract: VerifierSourcesRegistry): VerifierSourcesRegistryStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("VerifierSourcesRegistry", FIXTURE_BOC_PATH).hash());
            expect(data!.hash()).toEqual(EXPECTED_DATA_HASH);
            return VerifierSourcesRegistryStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Verifier Sources Registry is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Verifier Sources Registry is frozen at the pinned block");
        }
    }
}

get fun `test verifier sources registry code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("VerifierSourcesRegistry", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test verifier sources registry parses pinned storage and getters`() {
    val contract = registry();
    val storage = loadRegistryStorage(contract);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.minGram).toEqual(66000000);
    expect(storage.maxGram).toEqual(1100000000);
    expect(storage.adminAddress).toEqual(address(ADMIN_ADDRESS));
    expect(storage.verifierRegistryAddress).toEqual(address(VERIFIER_REGISTRY_ADDRESS));
    expect(storage.sourceItemCode.hash()).toEqual(EXPECTED_SOURCE_ITEM_CODE_HASH);

    expect(contract.getAdminAddress()).toEqual(storage.adminAddress);
    expect(contract.getVerifierRegistryAddress()).toEqual(storage.verifierRegistryAddress);
    val costs = contract.getDeploymentCosts();
    expect(costs.minGram).toEqual(storage.minGram);
    expect(costs.maxGram).toEqual(storage.maxGram);
    expect(contract.getSourceItemAddress(VERIFIER_TON_ORG_ID, VERIFIED_CODE_HASH)).toEqual(
        address(SOURCE_ITEM_ADDRESS),
    );

    println("VERIFIER_SOURCES_REGISTRY_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
