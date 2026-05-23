import { loadAbiRegistry } from "./load-schemas.js";

const registry = await loadAbiRegistry();
process.stdout.write(`${JSON.stringify(registry, null, 2)}\n`);
