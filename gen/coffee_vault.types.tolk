// Generated from XML ABI schemas.
// Source schema: schemas/swap_coffee.xml
// TL-B message bodies are generated from @ton-community/tlb-parser.

contract CoffeeVault {
    author: "Generated from ABI XML"
    version: "0.1"
    description: "Generated interface for schemas/swap_coffee.xml"
}

enum Errors {
    Unexpected = 250
    WrongSender = 252
    NotAFactory = 253
    WrongChain = 255
    WrongAssets = 256
    SameAssets = 257
    WrongSignature = 258
    InvalidBalance = 259
    InvalidAssetType = 267
}

get fun get_asset(): slice {
    return createEmptyCell().beginParse();
}

get fun is_active(): bool {
    return false;
}
