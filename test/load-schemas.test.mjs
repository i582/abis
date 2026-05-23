import assert from "node:assert/strict";
import test from "node:test";

import { generateTolkTypesFiles } from "../dist/generate-tolk.js";
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
});
