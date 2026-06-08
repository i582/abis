import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/fragment_username_collection.types"

get fun `test fragment username collection decodes real signed deploy body`() {
    val txHash = "loh5WgiSDFf8NQQ7pDIRZb/2wr2x1xLPoxRDB9BMtgc=";
    val txLt = "82360272000035";
    val bodyBoc = "te6cckEBBAEA6gADsUY3KJom1G2kTDti7SGQDaHkp4B5vcpo0CJAK32I1Ge7a3YwcjjlrVNexxjRaOCKpixXZFdnm/J6kADerlFiPmJAMoMMAAAAA2omvd1qJr5zB3hzcmt5aXbAAQIDAF4BaHR0cHM6Ly9uZnQuZnJhZ21lbnQuY29tL3VzZXJuYW1lL3hzcmt5aXYuanNvbgBhgBCtmQs4OVBWqqLCiv24rcquR6bZSdtloC1PVF+KeRToagSoF8gAAKAAAcIAASdQEABLAAUAZIAIEbR2UW2Ay0snwgciTTdVU4vxldeBjTs+FVd1ZVMkrXC8Vazm";
    val decoded = FragmentUsernameCollectionDeploy.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.subwalletId).toEqual(3);
    expect(decoded.validSince).toEqual(1780923869);
    expect(decoded.validTill).toEqual(1780924019);
    expect(decoded.command.remainingBitsCount()).toBeGreater(0);
    expect(decoded.command.remainingRefsCount()).toEqual(3);

    println("FRAGMENT_USERNAME_COLLECTION_DEPLOY_TX={} LT={} BODY={}", txHash, txLt, decoded);
}
