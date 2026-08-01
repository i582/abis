import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonkspump_custom_jetton_wallet.types"

const OWNER_ADDRESS = "0:E64C27985A548DCF2A3E6ADD0B957BE66725528509413E935E29CB845EF92AC9"
const JETTON_MASTER_ADDRESS = "0:2A5F463DA5DA433776D0D094146533AED926DC0BA4E2EF70F52DE5415DF63FC2"
const TAX_RECEIVER_ADDRESS = "0:A1D49D1BB076D4BC6B5131174A84C476C03BF9CB57125DCCFABDEBC1E8DD0DD0"
const CONTEXT_ADDRESS = "0:A6F6346AACCADAB68F29201C6D8AFEC0E5A6878087A1BC066766D4C514023453"

get fun `test sTONks wallet decodes a real owner transfer`() {
    val txHash = "CfxNHEP/6XBvGiChYN99cTk6o4CSmC+ssJBN6NmHAX8=";
    val txLt = "91215855000048";
    val body = parseCellFromBase64("te6cckEBAgEAXwABrA+KfqU67C2ULSS1H2GQuTu4i6gAsFRyjBJOc2AR8a095uH8sSo+p2JdI10ouxX5AHZ95r0AFgqOUYJJzmwCPjWnvNw/liVH1OxLpGulF2K/IA7PvNeBAQAILhz6gu3S3Gw=");
    val transfer = StonksPumpJettonTransfer.fromCell(body);

    expect(transfer.queryId).toEqual(4245818663139325215);
    expect(transfer.amount).toEqual(27537513875642);
    expect(transfer.destination).toEqual(
        address("0:582A3946092739B008F8D69EF370FE58951F53B12E91AE945D8AFC803B3EF35E"),
    );
    expect(transfer.responseDestination!).toEqual(
        address("0:582A3946092739B008F8D69EF370FE58951F53B12E91AE945D8AFC803B3EF35E"),
    );
    expect(transfer.customPayload).toBeNull();
    expect(transfer.forwardTonAmount).toEqual(0);
    expect(transfer.forwardPayload.remainingBitsCount()).toEqual(1);
    expect(transfer.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(transfer.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_OWNER_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test sTONks wallet decodes a real custom internal transfer`() {
    val txHash = "zJuoDyxuZVyIaqkDz6xWR4SCfJy/ONbvbGvioE8Muss=";
    val txLt = "91891535000026";
    val body = parseCellFromBase64("te6cckECBAEAARcAArYXjUUZjdleAQC/qV9wLCFnGtKMKABUvox7S7SGbu2hoSgoymddsk24F0nF3uHqW8qCu+x/hQAodSdG7B21LxrUTEXSoTEdsA7+ctXEl3M+r3rwejdDdBAvrwgDAQIAhYAcyYTzC0qRueVHzVuhcq98zOSqUKEoJ9JrxTlwi98lWTACm9jRqrMrato8pIBxtiv7A5aaHgIehvAZnZtTFFAI0U4BTeOg1IKAFN7GjVWZW1bR5SQDjbFf2By00PAQ9DeAzOzamKKARopgQAMAjgAAAACAFDqTo3YO2peNaiYi6VCYjtgHfzlq4ku5n1e9eD0boboQA/M/arrkMe7OMAcEd9n1ISS/giIVIk21QKQdTwAhMGBU8KeUuw==");
    val transfer = StonksPumpJettonInternalTransfer.fromCell(body);
    val context = transfer.transferContext.load();

    expect(transfer.queryId).toEqual(10221304187694590303);
    expect(transfer.amount).toEqual(776351605663938);
    expect(transfer.senderOwner!).toEqual(address(JETTON_MASTER_ADDRESS));
    expect(context.contextAddress0).toEqual(address(OWNER_ADDRESS));
    expect(context.contextAddress1).toEqual(address(CONTEXT_ADDRESS));
    expect(transfer.responseDestination!).toEqual(address(TAX_RECEIVER_ADDRESS));
    expect(transfer.forwardTonAmount).toEqual(200000000);
    expect(transfer.forwardPayload.remainingBitsCount()).toEqual(2);
    expect(transfer.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(transfer.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_INTERNAL_TRANSFER_TX={} LT={}", txHash, txLt);
}

get fun `test sTONks wallet decodes a real transfer notification`() {
    val txHash = "zJuoDyxuZVyIaqkDz6xWR4SCfJy/ONbvbGvioE8Muss=";
    val txLt = "91891535000026";
    val body = parseCellFromBase64("te6cckEBAwEArAABa3Ni0JyN2V4BAL+pX3AsIWca0owoAFS+jHtLtIZu7aGhKCjKZ12yTbgXScXe4epbyoK77H+FwAEBTeOg1IKAFN7GjVWZW1bR5SQDjbFf2By00PAQ9DeAzOzamKKARopgQAIAjgAAAACAFDqTo3YO2peNaiYi6VCYjtgHfzlq4ku5n1e9eD0boboQA/M/arrkMe7OMAcEd9n1ISS/giIVIk21QKQdTwAhMGBU32fE0Q==");
    val notification = StonksPumpJettonTransferNotification.fromCell(body);

    expect(notification.queryId).toEqual(10221304187694590303);
    expect(notification.amount).toEqual(776351605663938);
    expect(notification.senderOwner!).toEqual(address(JETTON_MASTER_ADDRESS));
    expect(notification.forwardPayload.remainingBitsCount()).toEqual(2);
    expect(notification.forwardPayload.remainingRefsCount()).toEqual(1);
    expect(notification.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_TRANSFER_NOTIFICATION_TX={} LT={}", txHash, txLt);
}

get fun `test sTONks wallet decodes the real cc1a97ab tax transfer`() {
    val txHash = "CfxNHEP/6XBvGiChYN99cTk6o4CSmC+ssJBN6NmHAX8=";
    val txLt = "91215855000048";
    val body = parseCellFromBase64("te6cckEBAQEAeQAA7cwal6s67C2ULSS1H2B0Nbe4FAgBzJhPMLSpG55UfNW6Fyr3zM5KpQoSgn0mvFOXCL3yVZMAOZMJ5haVI3PKj5q3QuVe+ZnJVKFCUE+k14py4Re+SrJgBTexo1VmVtW0eUkA42xX9gctNDwEPQ3gMzs2piigEaKcg8cnKg==");
    val transfer = StonksPumpJettonTaxTransfer.fromCell(body);

    expect(transfer.queryId).toEqual(4245818663139325215);
    expect(transfer.amount).toEqual(7985879023936);
    expect(transfer.senderOwner).toEqual(address(OWNER_ADDRESS));
    expect(transfer.contextAddress0).toEqual(address(OWNER_ADDRESS));
    expect(transfer.contextAddress1).toEqual(address(CONTEXT_ADDRESS));
    expect(transfer.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_CC1A97AB_TX={} LT={}", txHash, txLt);
}

get fun `test sTONks wallet decodes a real accepted bounce`() {
    val txHash = "MnX7Td1J6ohvjRC3kaOR2Cw7b2wcFrQ7LFdKog6DJbU=";
    val txLt = "87470642000046";
    val body = parseCellFromBase64("te6cckEBAQEAJgAASP////8XjUUZAAAAAAAAAABhnt38PsgIAcyYTzC0qRueVHzVupOCpBY=");
    val bounced = StonksPumpCustomJettonWalletBouncedKnownBody.fromCell(body);

    expect(bounced.originalOpcode).toEqual(0x178d4519);
    expect(bounced.queryId).toEqual(0);
    expect(bounced.amount).toEqual(28509452102784);
    expect(bounced.tail.remainingBitsCount() > 0).toBeTrue();
    expect(bounced.tail.remainingRefsCount()).toEqual(0);
    expect(bounced.toCell().hash()).toEqual(body.hash());
    println("STONKSPUMP_ACCEPTED_BOUNCE_TX={} LT={}", txHash, txLt);
}
