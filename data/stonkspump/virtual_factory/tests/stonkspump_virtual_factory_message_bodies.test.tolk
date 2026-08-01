import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonkspump_virtual_factory.types"

get fun `test decodes real stonkspump factory creation request`() {
    val txHash = "QTGCIoymf3Emr5NVv8++BwneLXU6AVcIRYq6dOVvleU=";
    val txLt = "93952838000003";
    val bodyBoc = "te6cckEBAgEAbAABacwamAEAAAAAAAAAAFBKgXyAAAZIAL0ovM5EdJm5U9q9bQkiA9KtqyF34NiIlhV9tbV8X1klAQBkAWh0dHBzOi8vYXBwLnN0b25rcy5jYXNoL2FwaS9qZXR0b24tbWV0YWRhdGEvMTEwMTEXfBfn";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpCreateVirtualLiquidityJetton.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.content.hash()).toEqual(
        0x4f6ee7953e3a05881c823a82956cc89992e80836b0231e8eeb4fe8446d7b3fdb,
    );
    expect(decoded.devBuyTonAmount).toEqual(20000000000);
    expect(decoded.maxBuyPercent).toEqual(100);
    expect(decoded.devWallet).toEqual(address("EQBelF5nIjpM3KntXraEkQHpVtWQu_BsREsKvtravi-skpfv"));
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_FACTORY_CREATE_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real minter initialization emitted by stonkspump factory`() {
    val txHash = "QTGCIoymf3Emr5NVv8++BwneLXU6AVcIRYq6dOVvleU=";
    val txLt = "93952838000003";
    val bodyBoc = "te6cckEBBAEAxwACV8wamAIAAAAAAAAAALAOjUpRAABACxorwuxQAAMA5+azu589hJNzReTwQAMkAQIBiYALw1iciDZXDcoO/h5bbEsNQ2y9u4I/pDi/AoCX4dNfWIIDABelF5nIjpM3KntXraEkQHpVtWQu/BsREsKvtravi+skoAMAUVBKgXyACAC9KLzORHSZuVPavW0JIgPSrashd+DYiJYVfbW1fF9ZJCAwAEOAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQ/MxwTg==";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = StonksPumpVirtualMinterFactoryInit.fromCell(body);
    val devBuy = decoded.devBuy.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.presaleOpen).toBeTrue();
    expect(decoded.migrationTonTarget).toEqual(2000000000000);
    expect(decoded.tonsCollected).toEqual(0);
    expect(decoded.baseJettonReserve).toEqual(100000000000000000);
    expect(decoded.additionalTonReserve).toEqual(1992015968062);
    expect(decoded.additionalJettonReserve).toEqual(49700598802325000);
    expect(decoded.maxBuyPercent).toEqual(100);
    expect(decoded.migrationConfig.hash()).toEqual(
        0x551fbb68947a2626b36a4b9aab760be173ddfa4edc4bd1bd1db7aebc98346cf8,
    );
    expect(devBuy.tonAmount).toEqual(20000000000);
    expect(devBuy.recipient).toEqual(address("EQBelF5nIjpM3KntXraEkQHpVtWQu_BsREsKvtravi-skpfv"));
    expect(devBuy.minJettonsOut).toEqual(1);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_FACTORY_MINTER_INIT_TX={} LT={}", txHash, txLt);
}
