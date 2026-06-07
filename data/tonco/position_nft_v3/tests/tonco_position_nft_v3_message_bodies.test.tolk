import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/tonco_position_nft_v3.types"

const TONCO_POOL_TSTON_USDT = "0:951AAB2CC50BABC6E434FFADA95D55CFB75D3EE9B0D9AD2A6798049D7E89926E"
const TONCO_POSITION_NFT_786 = "0:93350D09DFC0CCE1004B95A1C17E286D57BDB0DEA44D6CD2C5BCAD9C63406AD6"
const TONCO_POSITION_NFT_786_INITIAL_OWNER = "0:551FF3CD4F905EAD5B51CCED20422217C70657418A1B6F351C4A328A9E133381"
const TONCO_POSITION_NFT_786_PREVIOUS_OWNER = "0:7831FF12B0BCEF7699292760857E4AC1FE4D47C33531B9BD1A48BBEE9A36C2EE"
const TONCO_POSITION_NFT_786_TRANSFER_OWNER = "0:63C392BDA93C336FF41D81080B0D5B690EE8A06803489E7F371EDF1BDA5C26A4"

fun expectEmptyForwardPayload(payload: RemainingBitsAndRefs): void {
    var forwardPayload = payload;
    expect(forwardPayload.remainingBitsCount()).toEqual(1);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
    expect(forwardPayload.loadBool()).toBeFalse();
    expect(forwardPayload.remainingBitsCount()).toEqual(0);
    expect(forwardPayload.remainingRefsCount()).toEqual(0);
}

get fun `test tonco position nft v3 decodes real transfer body`() {
    val txHash = "lcKQKlOUldYuHPJ2Sm3zqVbi93EudD+WP+2sY2LLGyM=";
    val txLt = "78486697000007";
    val bodyBoc = "te6cckEBAQEAUwAAoV/MPRQAAAAAAAAAAIAMeHJXtSeGbf6DsCEBYattId0UDQBpE8/m49vje0uE1JABjw5K9qTwzb/QdgQgLDVtpDuigaANInn83Ht8b2lwmpAgKNTsSrw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPositionNftV3Transfer.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.newOwnerAddress).toEqual(address(TONCO_POSITION_NFT_786_TRANSFER_OWNER));
    expect(decoded.responseDestination).toBeNotNull();
    expect(decoded.responseDestination!).toEqual(address(TONCO_POSITION_NFT_786_TRANSFER_OWNER));
    expect(decoded.customPayload).toBeNull();
    expect(decoded.forwardTonAmount).toEqual(1);
    expectEmptyForwardPayload(decoded.forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_TRANSFER_TX={} LT={} NFT={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
    );
}

get fun `test tonco position nft v3 decodes real ownership assigned body`() {
    val txHash = "lcKQKlOUldYuHPJ2Sm3zqVbi93EudD+WP+2sY2LLGyM=";
    val txLt = "78486697000007";
    val bodyBoc = "te6cckEBAQEAMAAAWwUTjZEAAAAAAAAAAIAPBj/iVhed7tMlJOwQr8lYP8mo+GamNzejSRd900bYXcj9IaQ3";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPositionNftV3OwnershipAssigned.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.previousOwnerAddress).toEqual(address(TONCO_POSITION_NFT_786_PREVIOUS_OWNER));
    expectEmptyForwardPayload(decoded.forwardPayload);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_OWNERSHIP_ASSIGNED_TX={} LT={} NFT={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
    );
}

get fun `test tonco position nft v3 decodes real excesses body`() {
    val txHash = "lcKQKlOUldYuHPJ2Sm3zqVbi93EudD+WP+2sY2LLGyM=";
    val txLt = "78486697000007";
    val bodyBoc = "te6cckEBAQEADgAAGNUydtsAAAAAAAAAAPfBmNw=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPositionNftV3Excesses.fromCell(body);

    expect(decoded.queryId).toEqual(0);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_EXCESSES_TX={} LT={} NFT={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
    );
}

get fun `test tonco position nft v3 decodes real position init body`() {
    val txHash = "8B7xZYXpw+is4EHPega/aVhDySmNTSrdDQhtS8/e/cI=";
    val txLt = "65152367000017";
    val bodyBoc = "te6cckEBAgEApAABl9XsyioAAAAAAAAAAIAKo/55qfIL1atqOZ2kCERC+ODK6DFDbeajiUZRU8JmcCAAAAAAAAAAAAAAAAWeMBZf4NQf4YgAAAAAAAAJNdABAKYAAAAAAAAAAAAAAAAAAAAAFVYbAU/ZATOssBXAD/qNdAAAAAAAAAAAAAAAAAAAAAAACJIBZXT1GsCy7xEf3mNMAAAAAAAAAxJDGO7EUwuzi/8IiCvFIpE=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPositionNftV3PositionInit.fromCell(body);
    val oldFeeCell = decoded.oldFeeCell.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.userAddress).toEqual(address(TONCO_POSITION_NFT_786_INITIAL_OWNER));
    expect(decoded.liquidity).toEqual(754024626);
    expect(decoded.tickLower).toEqual(-63840);
    expect(decoded.tickUpper).toEqual(-62400);
    expect(decoded.poolSeqno).toEqual(18862);
    expect(oldFeeCell.feeGrowthInside0LastX128).toEqual(28360873170316347970735890393600789876);
    expect(oldFeeCell.feeGrowthInside1LastX128).toEqual(44499717297953139494699225824781132);
    expect(oldFeeCell.nftIndex).toEqual(786);
    expect(oldFeeCell.jetton0Amount).toEqual(831450181);
    expect(oldFeeCell.jetton1Amount).toEqual(766859);
    expect(oldFeeCell.tick).toEqual(-63352);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_POSITION_INIT_TX={} LT={} NFT={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
    );
}

get fun `test tonco position nft v3 decodes real position burn body`() {
    val txHash = "s5TOvwIaRMuvYzMh+2NZap3tOrH25dv+mvpvIxuzdqk=";
    val txLt = "78487539000021";
    val bodyBoc = "te6cckEBAgEAiQABh0bKM1oAAAAAAAAAAIAMeHJXtSeGbf6DsCEBYattId0UDQBpE8/m49vje0uE1IAAAAAAAAAAAAAAAAWeMBZf4NQf4YgQAQCAAAAAAAAAAAAAAAAAAAAAAB/RF8AuyvfoctnY3iTm588AAAAAAAAAAAAAAAAAAAAAAA5dbBd9ujVwgcgtHs5IOLGrSk8=";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = ToncoPositionNftV3PositionBurn.fromCell(body);
    val oldFeeCell = decoded.oldFeeCell.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.nftOwner).toEqual(address(TONCO_POSITION_NFT_786_TRANSFER_OWNER));
    expect(decoded.liquidity2Burn).toEqual(754024626);
    expect(decoded.tickLower).toEqual(-63840);
    expect(decoded.tickUpper).toEqual(-62400);
    expect(oldFeeCell.feeGrowthInside0LastX128).toEqual(42291739634475941941339267745213507535);
    expect(oldFeeCell.feeGrowthInside1LastX128).toEqual(74586984024329031990309934209058872);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_POSITION_BURN_TX={} LT={} NFT={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
    );
}

get fun `test tonco position nft v3 decodes real pool burn body`() {
    val txHash = "s5TOvwIaRMuvYzMh+2NZap3tOrH25dv+mvpvIxuzdqk=";
    val txLt = "78487539000021";
    val bodyBoc = "te6cckEBAwEA5AACt9c6wJ0AAAAAAAAAAIAMeHJXtSeGbf6DsCEBYattId0UDQBpE8/m49vje0uE1IAAAAAAAABiQAAAAAAAAAAAAAAABZ4wFl/g1B/hiAAAAAAAAAAAAAAAAAWeMBZQAQIAgAAAAAAAAAAAAAAAAAAAAAAVVhsBT9kBM6ywFcAP+o10AAAAAAAAAAAAAAAAAAAAAAAIkgFldPUawLLvER/eY0wAgAAAAAAAAAAAAAAAAAAAAAAf0RfALsr36HLZ2N4k5ufPAAAAAAAAAAAAAAAAAAAAAAAOXWwXfbo1cIHILR7OSDh37dHK";
    val body = parseCellFromBase64(bodyBoc);
    val decoded = Poolv3Burn.fromCell(body);
    val oldFeeCell = decoded.oldFeeCell.load();
    val newFeeCell = decoded.newFeeCell.load();

    expect(decoded.queryId).toEqual(0);
    expect(decoded.recipient).toEqual(address(TONCO_POSITION_NFT_786_TRANSFER_OWNER));
    expect(decoded.burnedIndex).toEqual(786);
    expect(decoded.liquidity).toEqual(754024626);
    expect(decoded.tickLower).toEqual(-63840);
    expect(decoded.tickUpper).toEqual(-62400);
    expect(decoded.liquidity2Burn).toEqual(754024626);
    expect(oldFeeCell.feeGrowthInside0LastX128).toEqual(28360873170316347970735890393600789876);
    expect(oldFeeCell.feeGrowthInside1LastX128).toEqual(44499717297953139494699225824781132);
    expect(newFeeCell.feeGrowthInside0CurrentX128).toEqual(42291739634475941941339267745213507535);
    expect(newFeeCell.feeGrowthInside1CurrentX128).toEqual(74586984024329031990309934209058872);
    expect(decoded.toCell().hash()).toEqual(body.hash());

    println(
        "TONCO_POSITION_NFT_V3_POOL_BURN_TX={} LT={} NFT={} POOL={}",
        txHash,
        txLt,
        TONCO_POSITION_NFT_786,
        TONCO_POOL_TSTON_USDT,
    );
}
