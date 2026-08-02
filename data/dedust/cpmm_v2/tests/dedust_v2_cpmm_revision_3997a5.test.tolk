import "@acton/build"
import "@acton/fmt"
import "@acton/fs"
import "@acton/emulation/scripts"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/dedust_v2_cpmm.types"
import "../wrappers/DedustV2Cpmm.gen"

// The 3997a5 root references the DeDust CPMM v2 PoolV1 library. PoolV1 and
// PoolV2 share this public wire ABI while using different library code.
const POOL_ADDRESS = "EQAEGspJNRpLvMDXeLrD8QcUNSNAP61jwgFQIJlOEPDCtwwi"
const FIXTURE_BOC_PATH = "data/dedust/cpmm_v2/testdata/DedustV2Cpmm_3997a5c1.boc"
const EXPECTED_BOC_MAGIC = 0xb5ee9c72
const EXPECTED_CODE_HASH = 0x3997a5c1ee8923e93cf3a6a98ea3ef9482c64dd8aea2ba8365689e14d99c760d
const ASSET_X = "0:65aac9b5e380eae928db3c8e238d9bc0d61a9320fdc2bc7a2f6c87d6fedf9208"
const ASSET_Y = "0:b113a994b5024a16719f69139328eb759596c38a25f59028b146fecdc3621dfe"
const ZERO_OWNER = "0:0000000000000000000000000000000000000000000000000000000000000000"
const ZERO_OWNER_POSITION = "0:0404f5b7b5485cf99f712f6f2d51032d6f93814eb0601103b59f428bfbd32d59"
const SWAP_EVENT_BODY_BOC = "te6cckEBBAEAjgACoXjnm6QgCBOBCoMUlu1BQAB+DGNRG6j+xoNsCZKGb6AhuAWD7BBuZVQVz2Z9FKlzeABNTqRk8IeOQPwD/ZYlzklW5WOmC0bf7dYjA1q3bVRPZQECASVi9eIkm0tlB7BTWlhgExWBzykYAwAPGA5UUBYkGAQALQR/e9S1AAPAQAg3iEjCk4TV3er15wzgV7b36Q=="
const SWAP_INITIATOR = "0:07e0c63511ba8fec6836c0992866fa021b80583ec106e655415cf667d14a9737"
const SWAP_RECIPIENT = "0:26a752327843c7207e01fecb12e724ab72b1d305a36ff6eb1181ad5bb6aa27b2"

fun pool(): DedustV2Cpmm {
    return DedustV2Cpmm.fromAddress(address(POOL_ADDRESS));
}

fun hasBocMagic(bytes: slice): bool {
    return bytes.remainingBitsCount() >= 32 && bytes.preloadUint(32) == EXPECTED_BOC_MAGIC;
}

get fun `test DeDust CPMM v2 revision fixture has exact live code hash`() {
    val rawCodeBoc = fs.readBytes(FIXTURE_BOC_PATH);
    expect(rawCodeBoc).toBeNotNull();
    expect(hasBocMagic(rawCodeBoc!)).toBeTrue();
    expect(build("DedustV2Cpmm", FIXTURE_BOC_PATH).hash()).toEqual(EXPECTED_CODE_HASH);
}

get fun `test DeDust CPMM v2 revision parses pinned storage and getters`() {
    val contract = pool();
    expect(scripts.isContractDeployed(contract.address)).toBeTrue();

    val account = testing.getAccountState(contract.address);
    expect(account).toBeNotNull();

    match (account!.storage.state) {
        TlbAccountStateActive => {
            val code = account!.storage.state.stateInit.code;
            val data = account!.storage.state.stateInit.data;
            expect(code).toBeNotNull();
            expect(data).toBeNotNull();
            expect(code!.hash()).toEqual(EXPECTED_CODE_HASH);
            expect(code!.hash()).toEqual(build("DedustV2Cpmm", FIXTURE_BOC_PATH).hash());

            val storage = DedustV2CpmmStorage.fromCell(data!);
            val reply = contract.getPoolData();
            expect(reply.status).toEqual(2);
            expect(reply.depositActive).toBeTrue();
            expect(reply.swapActive).toBeTrue();
            expect(reply.assetX).toEqual(address(ASSET_X));
            expect(reply.assetY).toEqual(address(ASSET_Y));
            expect(reply.walletsByAssets).toBeNotNull();
            expect(reply.assetsByWallets).toBeNotNull();
            expect(reply.walletsByAssets!.hash()).toBeGreater(0);
            expect(reply.assetsByWallets!.hash()).toBeGreater(0);
            expect(reply.baseFeeBps).toEqual(100);
            expect(reply.reserveX).toEqual(52081348687030);
            expect(reply.reserveY).toEqual(33023023704);
            expect(reply.liquidity).toEqual(1311443317393);
            expect(reply.protocolFeeX).toEqual(0);
            expect(reply.protocolFeeY).toEqual(2138821813);
            expect(reply.creatorFeeX).toEqual(0);
            expect(reply.creatorFeeY).toEqual(0);
            expect(reply.xFeePerLiquidity).toEqual(0);
            expect(reply.yFeePerLiquidity).toEqual(5194900905467489393499215091964979);
            expect(storage.depositActive).toEqual(reply.depositActive);
            expect(storage.swapActive).toEqual(reply.swapActive);
            expect(storage.reserveX).toEqual(reply.reserveX);
            expect(storage.reserveY).toEqual(reply.reserveY);
            expect(storage.liquidity).toEqual(reply.liquidity);
            match (storage.status) {
                DedustV2CpmmStatusInitialized => {}
                DedustV2CpmmStatusUninitialized => {
                    Assert.fail("DeDust CPMM v2 PoolV1 is unexpectedly uninitialized");
                }
                DedustV2CpmmStatusInitializing => {
                    Assert.fail("DeDust CPMM v2 PoolV1 is unexpectedly initializing");
                }
            }
            expect(contract.getPositionAddress(address(ZERO_OWNER))).toEqual(
                address(ZERO_OWNER_POSITION),
            );
        }
        TlbAccountStateUninit => {
            Assert.fail("DeDust CPMM v2 revision is uninitialized at the pinned block");
        }
        TlbAccountStateFrozen => {
            Assert.fail("DeDust CPMM v2 revision is frozen at the pinned block");
        }
    }
}

get fun `test DeDust CPMM v2 PoolV1 decodes exact live swap event`() {
    val body = parseCellFromBase64(SWAP_EVENT_BODY_BOC);
    val decoded = DedustV2CpmmSwapEvent.fromCell(body);
    val nextState = decoded.nextState.load();
    val poolFees = nextState.fees.load();
    val swapFees = decoded.fees.load();

    expect(decoded.xToY).toBeFalse();
    expect(decoded.amountIn).toEqual(16936993);
    expect(decoded.amountOut).toEqual(26460674690);
    expect(decoded.initiatorAddress).toEqual(address(SWAP_INITIATOR));
    expect(decoded.recipientAddress).toEqual(address(SWAP_RECIPIENT));

    expect(nextState.reserveX).toEqual(52081348687030);
    expect(nextState.reserveY).toEqual(33023023704);
    expect(nextState.liquidity).toEqual(1311443317393);
    expect(poolFees.protocolFeeX).toEqual(0);
    expect(poolFees.protocolFeeY).toEqual(2138821813);
    expect(poolFees.creatorFeeX).toEqual(0);
    expect(poolFees.creatorFeeY).toEqual(0);
    expect(poolFees.xFeePerToken.value).toEqual(0);
    expect(poolFees.yFeePerToken.value).toEqual(5194900905467489393499215091964979);

    expect(swapFees.isX).toBeFalse();
    expect(swapFees.lpFee).toEqual(117386);
    expect(swapFees.creatorFee).toEqual(0);
    expect(swapFees.protocolFee).toEqual(50307);
    expect(swapFees.partnerFee).toEqual(0);
    expect(swapFees.referrerFee).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
