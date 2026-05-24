import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import test from "node:test";

import {
  generateContractCodeHashesMap,
  generateTolkTypesFiles,
} from "../dist/generate-tolk.js";
import { loadAbiRegistry } from "../dist/load-schemas.js";

test("loads every XML schema into the typed registry", async () => {
  const registry = await loadAbiRegistry();

  assert.equal(registry.schemas.length, 36);

  const invoices = registry.schemas.find((schema) => schema.schemaId === "invoices");
  assert.ok(invoices);
  assert.equal(invoices.types.length, 2);
  assert.equal(invoices.messages.length, 2);

  const tonvalidators = registry.schemas.find(
    (schema) => schema.schemaId === "tonvalidators",
  );
  assert.ok(tonvalidators);

  const listNominators = tonvalidators.getMethods.find(
    (method) => method.name === "list_nominators",
  );
  assert.ok(listNominators?.output);
  assert.equal(listNominators.output.fields[0]?.kind, "tuple");
});

test("prints Tolk generation diagnostics to stdout", () => {
  const outDir = "/tmp/abis-tolk-test-cli";
  const result = spawnSync(
    process.execPath,
    ["dist/generate-tolk-cli.js", "--out", outDir],
    { encoding: "utf8" },
  );

  assert.equal(result.status, 0);
  assert.match(result.stdout, /Generated contract code hash map/);
  assert.match(
    result.stdout,
    /bidask_pool\.types\.tolk: incomingMessages: not added to contract header because bidask_swap_fallback and bidask_swap_fallback_v2 share opcode/,
  );

  const codeHashes = JSON.parse(
    readFileSync(`${outDir}/contract-code-hashes.json`, "utf8"),
  );
  assert.deepEqual(codeHashes.MoonBooster, [
    "ce84c382c8b6ac0d05212bbaa34d05e54e1e30e2cc9289f2d9c9d64726a112a8",
  ]);
});

test("generates first-pass Tolk type files from loaded schemas", async () => {
  const registry = await loadAbiRegistry();
  const files = generateTolkTypesFiles(registry, "/tmp/abis-tolk-test");

  assert.equal(files.length, 130);

  const walletV4r2 = files.find((file) => file.fileName === "wallet_v4r2.types.tolk");
  assert.ok(walletV4r2);
  assert.match(walletV4r2.source, /contract WalletV4r2 \{/);
  assert.match(walletV4r2.source, /enum Errors \{/);
  assert.match(walletV4r2.source, /get fun seqno\(\): uint32/);
  assert.doesNotMatch(walletV4r2.source, /contract\.getAddress\(\)/);

  const smartAccount = files.find((file) => file.fileName === "smart_account.types.tolk");
  assert.ok(smartAccount);
  assert.match(smartAccount.source, /get fun `processed\?`/);
  assert.match(smartAccount.source, /createEmptyCell\(\)/);

  const hipoFinance = files.find((file) => file.fileName === "hipo_finance.types.tolk");
  assert.ok(hipoFinance);
  assert.match(hipoFinance.source, /incomingMessages: HipoFinanceIncomingMessage/);
  assert.match(hipoFinance.source, /struct \(0x3d3761a6\) HipoFinanceDepositCoins/);

  const walletV5r1 = files.find((file) => file.fileName === "wallet_v5r1.types.tolk");
  assert.ok(walletV5r1);
  assert.match(walletV5r1.source, /incomingExternal: WalletV5r1IncomingExternalMessage/);

  const dns = files.find((file) => file.fileName === "dns.types.tolk");
  assert.ok(dns);
  assert.match(dns.source, /type DnsOutgoingMessage = DnsBalanceRelease\n\nstruct DnsresolveReply/);

  const tegro = files.find((file) => file.fileName === "tegro.types.tolk");
  assert.ok(tegro);
  assert.match(tegro.source, /forceAbiExport: TegroJettonPayload/);
  assert.match(tegro.source, /struct \(0x287e167a\) TegroAddLiquidity/);
  assert.match(tegro.source, /struct \(0x01fb7a25\) TegroJettonSwap/);
  assert.match(tegro.source, /type TegroJettonPayload =\n    \| TegroAddLiquidity\n    \| TegroJettonSwap/);

  const bidaskPool = files.find((file) => file.fileName === "bidask_pool.types.tolk");
  assert.ok(bidaskPool);
  assert.match(bidaskPool.source, /forceAbiExport: BidaskPoolIncomingMessage/);
  assert.ok(
    bidaskPool.diagnostics.some((diagnostic) =>
      diagnostic.includes("bidask_swap_fallback and bidask_swap_fallback_v2 share opcode"),
    ),
  );

  const moonBooster = files.find((file) => file.fileName === "moon_booster.types.tolk");
  assert.ok(moonBooster);
  assert.match(
    moonBooster.source,
    /Code hash: ce84c382c8b6ac0d05212bbaa34d05e54e1e30e2cc9289f2d9c9d64726a112a8/,
  );
  assert.match(
    moonBooster.source,
    /type MoonBoosterOutgoingMessage = MoonBoostPool\n\nget fun get_status/,
  );
});

test("generates contract name to code hashes map", async () => {
  const registry = await loadAbiRegistry();
  const codeHashes = generateContractCodeHashesMap(registry);

  assert.deepEqual(codeHashes.MoonBooster, [
    "ce84c382c8b6ac0d05212bbaa34d05e54e1e30e2cc9289f2d9c9d64726a112a8",
  ]);
  assert.deepEqual(codeHashes.WalletV5r1, [
    "20834b7b72b112147e1b2fb457b84e74d1a30f04f737d4f62a668e9552d2b72f",
  ]);
  assert.equal(codeHashes.DedustVault, undefined);
});
