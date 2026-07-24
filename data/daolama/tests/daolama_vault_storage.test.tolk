import "@acton/fmt"
import "@acton/io"
import "@acton/testing/expect"
import "../types/daolama_vault.types"

const DAOLAMA_VAULT_DATA_BOC = "te6ccgECEwEAA7UAAjUwPONilpHbE03AUd0AMQf79Sl8qwFOeC8oDUABAgKDtu0ihCR57LC6La+vOdQ9Tza0ehl/67nmN9Jne0TnQdWAHhzInuOuC99HPLP0ckKXNdSgR13z3xSGPz9266bR+vuQAwQAE3ARDZMW7AAAJYgBFP8A9KQT9LzyyAsFAGABaHR0cHM6Ly9hc3NldHMuZGFvbGFtYS5jby9scC10b2tlbi90b24tZGxwLmpzb24CAWIGBwICywgJABug9gXaiaH0AfSB9IGoYQC30IMcAkl8E4AHQ0wMBcbCVE18D8Bbg+kD6QDH6ADFx1yH6ADH6ADAC0x8hghAPin6lupUxNFnwE+AhghAXjUUZupYxREQD8BTgNYIQWV8HvLqTWfAV4F8EhA/y8ICAUgKCwH18B6Z/9AH0gOBF9IhhdeXCm9qJofQB9IH0gahgom1CpFWOC+XFglGF/+XFhKhohOCoQCaoKAeQoAn0BLGeLAOeLZmSRZGWAiXoAegBlgGSQfIA4OmRlgWUD5f/k6AJ9IHoCGP0AEGuk4QB5cWI7wAxkZYKoBGeLOH0BC8DAIBIA0OAKbLaxPMghAXjUUZyMsfGcs/UAf6AiLPFlAGzxYl+gJQA88WyVAFzCORcpFx4lAIqBOgggnJw4CgFLzy4sUEyYBA+wAQI8hQBPoCWM8WAc8WzMntVAIBIA8QAIFIAg1yHtRND6APpA+kDUMATTHyGCEBeNRRm6AoIQe92X3roSsfLixdM/MfoAMBOgUCPIUAT6AljPFgHPFszJ7VSAL3O1E0PoA+kD6QNQwCNM/+gBRUaAF+kD6QFNbxwVUc21wVCATVBQDyFAE+gJYzxYBzxbMySLIywES9AD0AMsAyfkAcHTIywLKB8v/ydBQDccFHLHy4sMK+gBRqKGCCJiWgGa2CKGCCJiWgKAYoSeXEEkQODdfBOMNJdcLAYBESANc7UTQ+gD6QPpA1DAH0z/6APpAMFFRoVJJxwXy4sEnwv/y4sIFggkxLQCgFrzy4sOCEHvdl97Iyx8Vyz9QA/oCIs8WAc8WyXGAGMjLBSTPFnD6AstqzMmAQPsAQBPIUAT6AljPFgHPFszJ7VSAAcFJ5oBihghBzYtCcyMsfUjDLP1j6AlAHzxZQB88WyXGAGMjLBSTPFlAG+gIVy2oUzMlx+wAQJBAjAHzDACPCALCOIYIQ1TJ223CAEMjLBVAIzxZQBPoCFstqEssfEss/yXL7AJM1bCHiA8hQBPoCWM8WAc8WzMntVA=="
const DAOLAMA_VAULT_DATA_HASH = 0xb8ff08be56dd52f055ed468f4dc49f6d74efab77f696f7fecd931f4fd32627a9
const DAOLAMA_CONFIG_HASH = 0xfbee693b1af5772f5651a962f80226e044cdaeeb12fff60bc84661a8e3dcc52b
const DAOLAMA_PARAMS_HASH = 0xe584734ed370cd688a5c862bd36679c6f558a649ae76f53e46f6483922a0419b

get fun `test daolama vault decodes real mainnet storage`() {
    // Toncenter account-state snapshot for daolama-ton-vault.ton on 2026-07-24.
    val data = parseCellFromBase64(DAOLAMA_VAULT_DATA_BOC);
    val storage = DaolamaVaultStorage.fromCell(data);
    val config = DaolamaVaultConfig.fromCell(storage.config);
    val params = DaolamaVaultParams.fromCell(storage.params);

    expect(data.hash()).toEqual(DAOLAMA_VAULT_DATA_HASH);
    expect(storage.config.hash()).toEqual(DAOLAMA_CONFIG_HASH);
    expect(storage.params.hash()).toEqual(DAOLAMA_PARAMS_HASH);
    expect(storage.halted).toBeFalse();
    expect(storage.balance).toEqual(8368413659707);
    expect(storage.borrowed).toEqual(42449320000000);
    expect(storage.lpTokenBalance).toEqual(36281713504149);
    expect(storage.feeCollected).toEqual(2873070866458);

    expect(config.authorizationPublicKey).toEqual(
        0xb6ed22842479ecb0ba2dafaf39d43d4f36b47a197febb9e637d2677b44e741d5 as uint256,
    );
    expect(config.adminAddress).toEqual(
        address("0:F0E644F71D705EFA39E59FA39214B9AEA5023AEF9EF8A431F9FBB75D368FD7DC"),
    );
    expect(config.jettonWalletCode.hash()).toEqual(
        0x1b9c374c91cf251615da603055fe7fdee1effe45a21536cdd97eedec16675428,
    );
    expect(config.jettonContent.hash()).toEqual(
        0x9db65f27d2880fb8401997e8293f547984b302f188deb2205334e27754c085a2,
    );

    expect(params.maxTotalLiquidity).toEqual(300000000000000);
    expect(params.profitFeePerMille).toEqual(600);
}
