import "@acton/fmt"
import "@acton/testing/expect"
import "../types/dedust_v2_cpmm.types"

const PAY_NATIVE_BODY_BOC = "te6cckEBAwEAkQACI6Wny/iN2V4BAHrmz1AdzWUACAECACHEQlAPcFk91gAqXHAGonZY4QDLgBZoWGILz/BWQHkWxpyThZsEDXJRvnBXfBm2mPrww8xPoEALNCwxBef4KyA8i2NOScLNgga5KN84K74M20x9eGHmJ9AgBZoWGILz/BWQHkWxpyThZsEDXJRvnBXfBm2mPrww8xPst9DDeQ=="
const SWAP_EVENT_BODY_BOC = "te6cckEBBAEAoAACp3jnm6SoDuaygAODGUIY5QbEQAs0LDEF5/grIDyLY05Jws2CBrko3zgrvgzbTH14YeYn2AFmhYYgvP8FZAeRbGnJOFmwQNclG+cFd8GbaY+vDDzE+wECAS1gEwvpwF9oA/ngt03Q0dBwIs8xF/+LKAMAG6APG5MKAPG5MB+NyYAEADdQf7XF0ABQ/2uLxRBwOrOV3OkWiPljufrS7hggwwZ3Ww=="

get fun `test dedust v2 cpmm decodes live pay native body`() {
    val body = parseCellFromBase64(PAY_NATIVE_BODY_BOC);
    val decoded = DedustV2CpmmPayNative.fromCell(body);

    expect(decoded.queryId).toEqual(10221304187690084047);
    expect(decoded.amount).toBeGreater(0);
    expect(decoded.routeStep.hash()).toBeGreater(0);
    expect(decoded.swapParams.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}

get fun `test dedust v2 cpmm decodes live swap event body`() {
    val body = parseCellFromBase64(SWAP_EVENT_BODY_BOC);
    val decoded = DedustV2CpmmSwapEvent.fromCell(body);

    expect(decoded.flag).toBeTrue();
    expect(decoded.amount0).toBeGreater(0);
    expect(decoded.amount1).toBeGreater(0);
    expect(decoded.address0).toEqual(address("0:B342C3105E7F82B203C8B634E49C2CD8206B928DF382BBE0CDB4C7D7861E627D"));
    expect(decoded.address1).toEqual(address("0:B342C3105E7F82B203C8B634E49C2CD8206B928DF382BBE0CDB4C7D7861E627D"));
    expect(decoded.details0.hash()).toBeGreater(0);
    expect(decoded.details1.hash()).toBeGreater(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
}
