import "@acton/emulation/network"
import "@acton/emulation/testing"
import "@acton/testing/expect"
import "../types/jetton_discovery.types"
import "../wrappers/JettonDiscovery.gen"

get fun `test jetton discovery local deploy and provide wallet address`() {
    val sender = testing.treasury("jetton-discovery-local-sender");
    val discovery = JettonDiscovery.fromStorage({
        jettonMinterAddress: sender.address,
        jettonWalletCode: createEmptyCell(),
    });

    val deployTxs = discovery.deploy(sender.address, { value: ton("1"), bounce: false });
    expect(deployTxs).toHaveSuccessfulTx({
        from: sender.address,
        to: discovery.address,
        exitCode: 0,
    });

    val provideTxs = discovery.sendProvideWalletAddress(
        sender.address,
        31,
        sender.address,
        true,
        { value: ton("0.05"), bounce: false },
    );

    expect(provideTxs).toHaveSuccessfulTx<ProvideWalletAddress>({
        from: sender.address,
        to: discovery.address,
        exitCode: 0,
    });
}
