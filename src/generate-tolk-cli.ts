import path from "node:path";

import {
  CONTRACT_CODE_HASHES_FILE_NAME,
  writeTolkTypesFiles,
} from "./generate-tolk.js";
import { loadAbiRegistry } from "./load-schemas.js";

const outDir = resolveOutDir(process.argv.slice(2));
const registry = await loadAbiRegistry();
const files = await writeTolkTypesFiles(registry, outDir);

process.stdout.write(`Generated ${files.length} Tolk type files into ${outDir}\n`);
process.stdout.write(
  `Generated contract code hash map into ${path.join(outDir, CONTRACT_CODE_HASHES_FILE_NAME)}\n`,
);
for (const diagnostic of collectDiagnostics(files)) {
  process.stdout.write(`${diagnostic}\n`);
}

function collectDiagnostics(
  files: Awaited<ReturnType<typeof writeTolkTypesFiles>>,
): string[] {
  const seen = new Set<string>();
  const result: string[] = [];

  for (const file of files) {
    for (const diagnostic of file.diagnostics) {
      const line = `${file.fileName}: ${diagnostic}`;
      if (seen.has(line)) {
        continue;
      }
      seen.add(line);
      result.push(line);
    }
  }

  return result;
}

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
