import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/fragment_numbers_collection.types"

get fun `test fragment numbers collection decodes real signed deploy body`() {
    val txHash = "5yyjuej9nxlICKfWSh4ptz+4Xaaup63LJrb8lL3USPs=";
    val txLt = "59639178000003";
    val bodyBoc = "te6cckECBgEAAVAABLFGNyibMPCyVEWwgUf4fiITDkIeTxWMrRnyU6BIXVbJZbU3OYOWwK07D3a+GG1SsUR3yXBosM/R+ed9gr6XOkbW33BKBgAAAAxofkLGaH5SAgc4ODg4NTcw4AECAwQBAgEFAGeAFu0adxJXJcB2ypELyH0ZcNre/iOoG7Quwr5Q7TpYSy3IBycOAIBycOAAoAABwgABJ1AQAEsABQBkgAgRtHZRbYDLSyfCByJNN1VTi/GV14GNOz4VV3VlUyStcACGwAt2jTuJK5LgO2VIheQ+jLhtb38R1A3aF2FfKHadLCWW7AC3aNO4krkuA7ZUiF5D6MuG1vfxHUDdoXYV8odp0sJZbgCQaHR0cHM6Ly9zb2Z0d2FyZW1hZXN0cm8xNi5naXRodWIuaW8vbmZ0X2NvbGxlY3Rpb24vYW5vbl9udW0vODg4ODU3MC5qc29upaxlmg==";
    val decoded = FragmentNumbersCollectionDeploy.fromCell(parseCellFromBase64(bodyBoc));

    expect(decoded.subwalletId).toEqual(12);
    expect(decoded.validSince).toEqual(1753105094);
    expect(decoded.validTill).toEqual(1753108994);
    expect(decoded.command.remainingBitsCount()).toBeGreater(0);
    expect(decoded.command.remainingRefsCount()).toEqual(4);

    println("FRAGMENT_NUMBERS_COLLECTION_DEPLOY_TX={} LT={} BODY={}", txHash, txLt, decoded);
}
