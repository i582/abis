import "@acton/build"
import "@acton/fs"
import "@acton/io"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/grambo_jetton_master.types"
import "../wrappers/GramboJettonMaster.gen"

const MASTER_ADDRESS = "EQBom4slLIetxxKbAMYRD61BQwsxRnR_Tm0AO5ejiXsSYuYT"
const ACTIVATED_WALLET_OWNER = "kQCIkesakSwRZ9Hk3Z_yJ3tHMwgIF4CTLskOhT2BcIapqO54"
const ACTIVATED_WALLET_ADDRESS = "EQCI95BVEikEt6g3ksm4W-HEPP8FMUa_Bi3f7r1CPQJlxGdv"
const FIXTURE_BOC_PATH = "data/grambo/jetton_master/testdata/GramboJettonMaster.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x4ebda3bf29d21ade055af1d8670db72b49f331edbc453f8185b513be6f64e376
const PINNED_MAINNET_BLOCK = 83374906

fun master(): GramboJettonMaster {
    return GramboJettonMaster.fromAddress(address(MASTER_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

fun loadMasterStorage(contract: GramboJettonMaster): GramboJettonMasterStorage {
    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("GramboJettonMaster", FIXTURE_BOC_PATH).hash());
            return GramboJettonMasterStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("Grambo Jetton Master is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("Grambo Jetton Master is frozen at the pinned block");
        }
    }
}

get fun `test grambo master code fixture matches mainnet`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("GramboJettonMaster", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test grambo master parses pinned storage and getters`() {
    val contract = master();
    val storage = loadMasterStorage(contract);
    val curve = storage.curveState.load();
    val curveGetter = contract.getCurveState();
    val jetton = contract.getJettonData();
    val buyQuote = contract.getAmountOut(1000000000);
    val sellQuote = contract.getTonOut(1000000000);
    val walletAddress = contract.getWalletAddress(address(ACTIVATED_WALLET_OWNER) as any_address);

    expect(scripts.isContractDeployed(contract.address)).toBeTrue();
    expect(storage.virtualTonReserve).toEqual(curveGetter.virtualTonReserve);
    expect(storage.tonTarget).toEqual(curveGetter.tonTarget);
    expect(curve.collectedTon).toEqual(curveGetter.collectedTon);
    expect(curve.tokensSold).toEqual(curveGetter.tokensSold);
    expect(curve.graduated).toEqual(curveGetter.graduated);
    expect(storage.totalSupply).toEqual(jetton.totalSupply);
    expect(storage.metadata).toEqual(jetton.jettonContent);
    expect(storage.walletCode).toEqual(jetton.jettonWalletCode);
    expect(buyQuote).toBeGreaterOrEqual(0);
    expect(sellQuote).toBeGreaterOrEqual(0);
    expect(walletAddress.castToInternal()).toEqual(address(ACTIVATED_WALLET_ADDRESS));
    println("GRAMBO_MASTER_PINNED_MAINNET_BLOCK={}", PINNED_MAINNET_BLOCK);
}
