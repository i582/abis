import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/assert"
import "@acton/testing/expect"
import "@acton/types/transaction"
import "../types/sbt_v1_item.types"
import "../types/sbt_v1_single.types"
import "../wrappers/SbtV1Item.gen"
import "../wrappers/SbtV1Single.gen"

const MAINNET_SBT_V1_ITEM_ADDRESS = "EQCeAQzHYeZ4qLnXYevsOOElwxTuNdZfzwxF6vy4wegbSq5h"
const MAINNET_SBT_V1_SINGLE_ADDRESS = "EQBamoka0hrsZjwRa1qedfufUcaapBfxyQiLdRbTMDH7H1sq"

fun mainnetSbtV1Item(): SbtV1Item {
    return SbtV1Item.fromAddress(address(MAINNET_SBT_V1_ITEM_ADDRESS));
}

fun mainnetSbtV1Single(): SbtV1Single {
    return SbtV1Single.fromAddress(address(MAINNET_SBT_V1_SINGLE_ADDRESS));
}

fun sbtV1InlineEmptyForwardPayload(): RemainingBitsAndRefs {
    return beginCell().storeUint(0, 1).endCell().beginParse();
}

fun localSbtV1SingleStorage(owner: address, editor: address, authority: address): SbtV1SingleStorage {
    return {
        ownerAddress: owner,
        editorAddress: editor,
        content: beginCell().storeUint(0x534254, 24).endCell(),
        authorityAddress: authority,
        revokedAt: 0,
    };
}

fun deployLocalSbtV1Single(owner: address, editor: address, authority: address): SbtV1Single {
    val deployer = testing.treasury("sbt-v1-single-local-deployer");
    val single = SbtV1Single.fromStorage(localSbtV1SingleStorage(owner, editor, authority));

    val txs = single.deploy(deployer.address, { value: ton("1"), bounce: false });
    expect(txs).toHaveSuccessfulTx({
        from: deployer.address,
        to: single.address,
        exitCode: 0,
    });

    return SbtV1Single.fromAddress(single.address);
}

fun loadSbtV1ItemStorageFromFork(item: SbtV1Item): SbtV1ItemStorage {
    val account = testing.getAccountState(item.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return SbtV1ItemStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("SBT v1 item mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("SBT v1 item mainnet fixture account is frozen");
        }
    }
}

fun loadSbtV1SingleStorageFromFork(single: SbtV1Single): SbtV1SingleStorage {
    val account = testing.getAccountState(single.address);
    expect(account).toBeNotNull();

    val accountState = account!.storage.state;
    match (accountState) {
        TlbAccountStateActive => {
            val data = accountState.stateInit.data;
            expect(data).toBeNotNull();
            return SbtV1SingleStorage.fromCell(data!);
        }
        TlbAccountStateUninit => {
            Assert.fail("SBT v1 single mainnet fixture account is uninitialized");
        }
        TlbAccountStateFrozen => {
            Assert.fail("SBT v1 single mainnet fixture account is frozen");
        }
    }
}
