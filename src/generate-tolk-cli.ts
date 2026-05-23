import path from "node:path";

import { writeTolkTypesFiles } from "./generate-tolk.js";
import { loadAbiRegistry } from "./load-schemas.js";

const outDir = resolveOutDir(process.argv.slice(2));
const registry = await loadAbiRegistry();
const files = await writeTolkTypesFiles(registry, outDir);

process.stdout.write(`Generated ${files.length} Tolk type files into ${outDir}\n`);

function resolveOutDir(args: string[]): string {
  const outIndex = args.findIndex((arg) => arg === "--out" || arg === "-o");
  if (outIndex !== -1) {
    const value = args[outIndex + 1];
    if (!value) {
      throw new Error("Expected output directory after --out");
    }
    return path.resolve(value);
  }

  const firstArg = args.find((arg) => !arg.startsWith("-"));
  if (firstArg) {
    return path.resolve(firstArg);
  }

  return "/tmp/abis-tolk";
}
