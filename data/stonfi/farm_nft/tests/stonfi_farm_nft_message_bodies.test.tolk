import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/stonfi_farm_nft.types"

const EXPECTED_OWNER = "0:CC42B7401EB514584287F61E92B3A91FE96D6289239550C68D3B83D87B9DE52E"

get fun `test decodes real stonfi farm nft claim request body`() {
    val txHash = "A3aKsMiEu5on2PI4eCG8JNMVFw9Ouvs7pOHrpvToEsw=";
    val txLt = "51860034000003";
    val body = parseCellFromBase64(
        "te6cckEBAQEAEAAAG3jZ8QkAAADaobl+rIBAd6KoPA==",
    );
    val decoded = StonfiFarmNftClaimRewards.fromCell(body);

    expect(decoded.queryId).toEqual(939016158892);
    expect(decoded.claimAll).toBeTrue();
    expect(decoded.poolIndex).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_FARM_NFT_CLAIM_TX={} LT={}", txHash, txLt);
}

get fun `test decodes real stonfi farm nft outgoing claim body`() {
    val txHash = "A3aKsMiEu5on2PI4eCG8JNMVFw9Ouvs7pOHrpvToEsw=";
    val txLt = "51860034000003";
    val body = parseCellFromBase64(
        "te6cckEBCAEApAABezllZYQAAADaobl+rAAAAAAAAAANYB5uQtemeAGYhW6APWoosIUP7D0lZ1I/0trFEkcqoY0adwew9zvKXQDAAQIBzQIDAgEgBAUCASAGBwAmAAAAAAAAAAAAAAAAAAAABJp8KAAmAAAAAAAAAAAAAAAAAAAAAylm/QAmAAAAAAAAAAAAAAAAAAAAG9vBewAmAAAAAAAAAAAAAAAAAAAAAEjW+oCmFqo=",
    );
    val decoded = StonfiFarmNftClaimRequest.fromCell(body);

    expect(decoded.queryId).toEqual(939016158892);
    expect(decoded.itemIndex).toEqual(13);
    expect(decoded.stakedTokens).toEqual(2091182291559);
    expect(decoded.ownerAddress).toEqual(address(EXPECTED_OWNER));
    expect(decoded.claimAll).toBeTrue();
    expect(decoded.poolIndex).toEqual(0);
    expect(decoded.claimedPerUnitRoot).toBeNotNull();
    expect(decoded.toCell().hash()).toEqual(body.hash());
    println("STONFI_FARM_NFT_OUTGOING_CLAIM_TX={} LT={}", txHash, txLt);
}
