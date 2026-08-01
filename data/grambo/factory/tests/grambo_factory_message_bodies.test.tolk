import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/grambo_factory.types"

get fun `test decodes real grambo factory deploy body`() {
    val txHash = "XUNwyMo0sNXx5w3+IYgKUWm42d+dZHroP0DAJwH/6o4=";
    val txLt = "92785092000003";
    val bodyBoc = "te6cckEBAwEAMwABJA1CleCDU+y1Wuo4Pl6NSlEAAAEBAgECADBodHRwczovL2thcHBhLmxvbC9MTVY1cnAkjsT8";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GramboFactoryDeploy.fromCell(body);

    expect(decoded.queryId).toEqual(9463167505694079038);
    expect(
        decoded.metadata.hash(),
    ).toEqual(0x8238e425493c10635e84a5df6edb285482edcfbbe5a0cf69c7494b20d02e3e43);
    expect(decoded.tonTarget).toEqual(1000000000000);
    expect(decoded.prebuyAmount).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("GRAMBO_FACTORY_DEPLOY_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real grambo launch body`() {
    val txHash = "XUNwyMo0sNXx5w3+IYgKUWm42d+dZHroP0DAJwH/6o4=";
    val txLt = "92785092000003";
    val bodyBoc = "te6cckEBAQEAOwAAcTcvGuODU+y1Wuo4PoAKDB3ZTWL7I2wasgitDRLr6tO9+UuVEyclNd7w5V4H9Kqe6DLSPL0alKIAAYrzzhI=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = GramboFactoryLaunch.fromCell(body);

    expect(decoded.queryId).toEqual(9463167505694079038);
    expect(decoded.buyer).toEqual(
        address("0:5060EECA6B17D91B60D590456868975F569DEFCA5CA8993929AEF7872AF03FA5"),
    );
    expect(decoded.virtualTonReserve).toEqual(341250238750);
    expect(decoded.tonTarget).toEqual(1000000000000);
    expect(decoded.prebuyAmount).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("GRAMBO_FACTORY_LAUNCH_TX={} LT={}", txHash, txLt);
}
