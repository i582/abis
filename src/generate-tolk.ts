import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import type {
  AbiField,
  AbiGetMethod,
  AbiInterface,
  AbiMessageReference,
  AbiRegistry,
  AbiSchema,
} from "./types.js";

const ZERO_ADDRESS =
  'address("0:0000000000000000000000000000000000000000000000000000000000000000")';

export interface GeneratedTolkFile {
  schemaId: string;
  interfaceName?: string;
  fileName: string;
  path: string;
  source: string;
}

export async function writeTolkTypesFiles(
  registry: AbiRegistry,
  outDir: string,
): Promise<GeneratedTolkFile[]> {
  const files = generateTolkTypesFiles(registry, outDir);

  await mkdir(outDir, { recursive: true });
  await Promise.all(
    files.map(async (file) => {
      await writeFile(file.path, file.source, "utf8");
    }),
  );

  return files;
}

export function generateTolkTypesFiles(
  registry: AbiRegistry,
  outDir: string,
): GeneratedTolkFile[] {
  return registry.schemas.flatMap((schema) => generateSchemaFiles(schema, outDir));
}

function generateSchemaFiles(schema: AbiSchema, outDir: string): GeneratedTolkFile[] {
  if (schema.interfaces.length === 0) {
    const fileName = `${safeFileStem(schema.schemaId)}.types.tolk`;
    return [
      {
        schemaId: schema.schemaId,
        fileName,
        path: path.join(outDir, fileName),
        source: renderTolkTypes({
          schema,
          contractName: toPascalCase(schema.schemaId),
          methods: schema.getMethods,
          errors: [],
          msgIn: [],
          msgOut: [],
        }),
      },
    ];
  }

  return schema.interfaces.map((abiInterface) => {
    const resolved = resolveInterface(schema, abiInterface);
    const fileName = `${safeFileStem(abiInterface.name)}.types.tolk`;

    return {
      schemaId: schema.schemaId,
      interfaceName: abiInterface.name,
      fileName,
      path: path.join(outDir, fileName),
      source: renderTolkTypes({
        schema,
        contractName: toPascalCase(abiInterface.name),
        methods: resolveInterfaceGetMethods(schema, resolved.getMethods),
        errors: resolved.errors,
        msgIn: resolved.msgIn,
        msgOut: resolved.msgOut,
      }),
    };
  });
}

interface RenderTolkParams {
  schema: AbiSchema;
  contractName: string;
  methods: AbiGetMethod[];
  errors: AbiInterface["errors"];
  msgIn: AbiMessageReference[];
  msgOut: AbiMessageReference[];
}

function renderTolkTypes(params: RenderTolkParams): string {
  const ctx: RenderContext = {
    declarations: [],
    usedTypeNames: new Set(),
  };

  const header: string[] = [];
  const body: string[] = [];

  header.push("// Generated from XML ABI schemas.");
  header.push(`// Source schema: schemas/${params.schema.fileName}`);
  header.push("// TL-B message bodies are intentionally not generated yet.");
  header.push("");
  header.push(`contract ${params.contractName} {`);
  header.push(`    author: "Generated from ABI XML"`);
  header.push(`    version: "0.1"`);
  header.push(
    `    description: "Generated interface for schemas/${escapeTolkString(
      params.schema.fileName,
    )}"`,
  );
  header.push(`}`);
  header.push("");

  const errorEnum = renderErrorsEnum(params.errors);
  if (errorEnum.length > 0) {
    body.push(...errorEnum, "");
  }

  const incomingType = renderMessageReferenceComment(
    "Incoming messages declared in XML",
    params.msgIn,
  );
  const outgoingType = renderMessageReferenceComment(
    "Outgoing messages declared in XML",
    params.msgOut,
  );

  if (incomingType.length > 0) {
    body.push(...incomingType, "");
  }
  if (outgoingType.length > 0) {
    body.push(...outgoingType, "");
  }

  const emittedMethodNames = new Set<string>();
  for (const method of params.methods) {
    if (emittedMethodNames.has(method.name)) {
      body.push(
        `// Skipped duplicate get method ${method.name}${formatVersionComment(
          method,
        )}; Tolk cannot declare two get methods with the same name.`,
      );
      body.push("");
      continue;
    }

    emittedMethodNames.add(method.name);
    body.push(...renderGetMethod(ctx, method), "");
  }

  return [...header, ...ctx.declarations, ...body].join("\n").trimEnd() + "\n";
}

interface RenderContext {
  declarations: string[];
  usedTypeNames: Set<string>;
}

function renderErrorsEnum(errors: AbiInterface["errors"]): string[] {
  if (errors.length === 0) {
    return [];
  }

  const result = ["enum Errors {"];
  const usedNames = new Set<string>();
  const usedCodes = new Set<string>();

  for (const error of errors) {
    if (!error.code || usedCodes.has(error.code)) {
      continue;
    }

    usedCodes.add(error.code);
    const baseName = error.text ? toPascalCase(error.text) : `Error${error.code}`;
    const name = uniqueName(baseName || `Error${error.code}`, usedNames);
    result.push(`    ${name} = ${formatErrorCode(error.code)}`);
  }

  result.push("}");
  return result.length > 2 ? result : [];
}

function renderMessageReferenceComment(
  title: string,
  refs: AbiMessageReference[],
): string[] {
  if (refs.length === 0) {
    return [];
  }

  const names = unique(
    refs.map((ref) => `${ref.kind}:${toPascalCase(ref.name)}`),
  );
  return [`// ${title}: ${names.join(", ")}`];
}

function renderGetMethod(ctx: RenderContext, method: AbiGetMethod): string[] {
  const input = method.input?.fields ?? [];
  const params = createNamedFields(input, "arg").map((field) => {
    return `${field.name}: ${renderFieldType(ctx, method, field.field)}`;
  });

  const output = method.output?.fields ?? [];
  const returnType = renderReturnType(ctx, method, output);
  const returnValue = renderReturnValue(ctx, method, output);

  return [
    `get fun ${renderGetMethodName(method.name)}(${params.join(", ")}): ${returnType} {`,
    `    return ${returnValue};`,
    `}`,
  ];
}

function renderReturnType(
  ctx: RenderContext,
  method: AbiGetMethod,
  fields: AbiField[],
): string {
  if (fields.length === 0) {
    return "void";
  }

  if (fields.length === 1) {
    const [field] = fields;
    if (!field) {
      throw new Error(`Missing output field for ${method.name}`);
    }
    return renderFieldType(ctx, method, field);
  }

  const replyName = uniqueTypeName(ctx, `${toPascalCase(method.name)}Reply`);
  renderStruct(ctx, replyName, method, fields);
  return replyName;
}

function renderReturnValue(
  ctx: RenderContext,
  method: AbiGetMethod,
  fields: AbiField[],
): string {
  if (fields.length === 0) {
    return "()";
  }

  if (fields.length === 1) {
    const [field] = fields;
    if (!field) {
      throw new Error(`Missing output field for ${method.name}`);
    }
    return renderDefaultValue(ctx, method, field);
  }

  const entries = createNamedFields(fields, "field").map((field) => {
    return `${field.name}: ${renderDefaultValue(ctx, method, field.field)}`;
  });
  return `{\n${entries.map((entry) => `        ${entry},`).join("\n")}\n    }`;
}

function renderStruct(
  ctx: RenderContext,
  typeName: string,
  ownerMethod: AbiGetMethod,
  fields: AbiField[],
): void {
  const lines = [`struct ${typeName} {`];
  for (const field of createNamedFields(fields, "field")) {
    lines.push(`    ${field.name}: ${renderFieldType(ctx, ownerMethod, field.field)}`);
  }
  lines.push("}", "");
  ctx.declarations.push(...lines);
}

function renderFieldType(
  ctx: RenderContext,
  ownerMethod: AbiGetMethod,
  field: AbiField,
): string {
  if (field.kind === "tuple") {
    const tupleName = uniqueTypeName(
      ctx,
      `${toPascalCase(ownerMethod.name)}${toPascalCase(field.name ?? "Item")}`,
    );
    renderStruct(ctx, tupleName, ownerMethod, field.fields);
    const baseType = field.list ? `lisp_list<${tupleName}>` : tupleName;
    return field.nullable ? `${baseType}?` : baseType;
  }

  const baseType = mapScalarType(field);
  return field.nullable ? `${baseType}?` : baseType;
}

function renderDefaultValue(
  ctx: RenderContext,
  ownerMethod: AbiGetMethod,
  field: AbiField,
): string {
  if (field.nullable) {
    return "null";
  }

  if (field.kind === "tuple") {
    if (field.list) {
      return "[]";
    }

    const entries = createNamedFields(field.fields, "field").map((child) => {
      return `${child.name}: ${renderDefaultValue(ctx, ownerMethod, child.field)}`;
    });
    return `{\n${entries.map((entry) => `        ${entry},`).join("\n")}\n    }`;
  }

  return defaultValueForScalarType(mapScalarType(field));
}

function mapScalarType(field: Extract<AbiField, { kind: "scalar" }>): string {
  const rawValueType = field.valueType.trim();
  const valueType = rawValueType.toLowerCase();
  const tag = field.tag.toLowerCase();

  if (valueType === "bool" || valueType === "boolean") {
    return "bool";
  }

  if (
    valueType === "coins" ||
    valueType === "grams" ||
    valueType === "varuint16" ||
    valueType === "(varuinteger 16)" ||
    valueType === "(varuint 16)"
  ) {
    return "coins";
  }

  if (
    valueType === "msgaddress" ||
    valueType === "msgaddressint" ||
    valueType === "address"
  ) {
    return "address";
  }

  if (valueType === "string" || valueType === "text") {
    return tag === "cell" ? "cell" : "string";
  }

  if (valueType === "[]byte") {
    return "slice";
  }

  const intType = normalizeIntegerType(rawValueType);
  if (intType) {
    return intType;
  }

  if (tag === "cell") {
    return "cell";
  }

  if (tag === "slice") {
    return "slice";
  }

  if (tag === "int" || tag === "tinyint") {
    return "int";
  }

  return "cell";
}

function normalizeIntegerType(type: string): string | null {
  const normalized = type.trim().toLowerCase();

  if (normalized === "int257") {
    return "int";
  }

  const bitsMatch = normalized.match(/^bits(\d+)$/u);
  if (bitsMatch?.[1]) {
    return `uint${bitsMatch[1]}`;
  }

  const intMatch = normalized.match(/^(u?int)(\d+)$/u);
  if (intMatch?.[1] && intMatch[2]) {
    return `${intMatch[1]}${intMatch[2]}`;
  }

  return null;
}

function defaultValueForScalarType(type: string): string {
  if (type.endsWith("?")) {
    return "null";
  }

  if (type === "bool") {
    return "false";
  }

  if (type === "address") {
    return ZERO_ADDRESS;
  }

  if (type === "cell") {
    return "createEmptyCell()";
  }

  if (type === "slice") {
    return "createEmptyCell().beginParse()";
  }

  if (type === "builder") {
    return "beginCell()";
  }

  if (type === "string") {
    return `""`;
  }

  if (type.startsWith("map<") || type.startsWith("lisp_list<")) {
    return "[]";
  }

  return "0";
}

function resolveInterface(schema: AbiSchema, abiInterface: AbiInterface): AbiInterface {
  const visited = new Set<string>();

  function visit(current: AbiInterface): AbiInterface {
    if (visited.has(current.name)) {
      return emptyResolvedInterface(current);
    }
    visited.add(current.name);

    const parent = current.inherits
      ? schema.interfaces.find((candidate) => candidate.name === current.inherits)
      : undefined;

    const inherited = parent ? visit(parent) : emptyResolvedInterface(current);

    return {
      name: current.name,
      attributes: current.attributes,
      codeHashes: [...inherited.codeHashes, ...current.codeHashes],
      getMethods: [...inherited.getMethods, ...current.getMethods],
      msgIn: [...inherited.msgIn, ...current.msgIn],
      msgOut: [...inherited.msgOut, ...current.msgOut],
      errors: [...inherited.errors, ...current.errors],
      ...(current.inherits !== undefined ? { inherits: current.inherits } : {}),
    };
  }

  return visit(abiInterface);
}

function emptyResolvedInterface(source: AbiInterface): AbiInterface {
  return {
    name: source.name,
    attributes: source.attributes,
    codeHashes: [],
    getMethods: [],
    msgIn: [],
    msgOut: [],
    errors: [],
    ...(source.inherits !== undefined ? { inherits: source.inherits } : {}),
  };
}

function resolveInterfaceGetMethods(
  schema: AbiSchema,
  refs: AbiInterface["getMethods"],
): AbiGetMethod[] {
  const resolved: AbiGetMethod[] = [];

  for (const ref of refs) {
    const candidates = schema.getMethods.filter((method) => method.name === ref.name);
    if (candidates.length === 0) {
      continue;
    }

    if (ref.version !== undefined) {
      const byVersion = candidates.find((method) => methodMatchesVersion(method, ref.version));
      const fallback = candidates[0];
      if (byVersion ?? fallback) {
        resolved.push((byVersion ?? fallback)!);
      }
      continue;
    }

    const method =
      candidates.find(
        (candidate) =>
          !candidate.version && !candidate.input?.version && !candidate.output?.version,
      ) ?? candidates[0];
    if (method) {
      resolved.push(method);
    }
  }

  return uniqueMethods(resolved);
}

function methodMatchesVersion(method: AbiGetMethod, version: string | undefined): boolean {
  if (version === undefined) {
    return false;
  }

  return (
    method.version === version ||
    method.input?.version === version ||
    method.output?.version === version
  );
}

function uniqueMethods(methods: AbiGetMethod[]): AbiGetMethod[] {
  const seen = new Set<string>();
  const result: AbiGetMethod[] = [];

  for (const method of methods) {
    const key = `${method.name}:${method.version ?? ""}:${method.input?.version ?? ""}:${
      method.output?.version ?? ""
    }`;
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    result.push(method);
  }

  return result;
}

interface NamedField {
  name: string;
  field: AbiField;
}

function createNamedFields(fields: AbiField[], fallbackPrefix: string): NamedField[] {
  const used = new Set<string>();

  return fields.map((field, index) => {
    const baseName = field.name ? toCamelCase(field.name) : `${fallbackPrefix}${index + 1}`;
    return {
      name: uniqueName(baseName || `${fallbackPrefix}${index + 1}`, used),
      field,
    };
  });
}

function uniqueTypeName(ctx: RenderContext, preferred: string): string {
  return uniqueName(preferred || "GeneratedType", ctx.usedTypeNames);
}

function uniqueName(preferred: string, used: Set<string>): string {
  const sanitized = sanitizeIdentifier(preferred);
  let candidate = sanitized || "Generated";
  let index = 2;

  while (used.has(candidate)) {
    candidate = `${sanitized}${index}`;
    index += 1;
  }

  used.add(candidate);
  return candidate;
}

function toPascalCase(value: string): string {
  const words = splitWords(value);
  if (words.length === 0) {
    return "Generated";
  }

  return words.map(capitalizeWord).join("");
}

function toCamelCase(value: string): string {
  const pascal = toPascalCase(value);
  return pascal.charAt(0).toLowerCase() + pascal.slice(1);
}

function splitWords(value: string): string[] {
  return value
    .trim()
    .replace(/([a-z0-9])([A-Z])/gu, "$1 $2")
    .split(/[^0-9A-Za-z]+/u)
    .map((part) => part.trim())
    .filter(Boolean);
}

function capitalizeWord(word: string): string {
  if (/^\d+$/u.test(word)) {
    return word;
  }
  return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
}

function sanitizeIdentifier(value: string): string {
  const sanitized = value.replace(/[^0-9A-Za-z_]/gu, "");
  if (!sanitized) {
    return "";
  }

  return /^\d/u.test(sanitized) ? `Value${sanitized}` : sanitized;
}

function safeFileStem(value: string): string {
  const stem = value
    .trim()
    .toLowerCase()
    .replace(/[^0-9a-z_-]+/gu, "_")
    .replace(/^_+|_+$/gu, "");
  return stem || "schema";
}

function unique<T>(values: T[]): T[] {
  return [...new Set(values)];
}

function formatErrorCode(code: string): string {
  return /^0x[0-9a-f]+$/iu.test(code) || /^\d+$/u.test(code) ? code : JSON.stringify(code);
}

function formatVersionComment(method: AbiGetMethod): string {
  const version = method.version ?? method.input?.version ?? method.output?.version;
  return version ? ` version ${version}` : "";
}

function escapeTolkString(value: string): string {
  return value.replace(/\\/gu, "\\\\").replace(/"/gu, '\\"');
}

function renderGetMethodName(name: string): string {
  if (/^[A-Za-z_][0-9A-Za-z_]*$/u.test(name)) {
    return name;
  }

  return `\`${name.replace(/\\/gu, "\\\\").replace(/`/gu, "\\`")}\``;
}
