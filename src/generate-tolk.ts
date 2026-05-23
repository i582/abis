import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import {
  ast as parseTlbAst,
  BuiltinOneArgExpr,
  BuiltinZeroArgs,
  CellRefExpr,
  CombinatorExpr,
  CondExpr,
  FieldAnonymousDef,
  FieldBuiltinDef,
  FieldCurlyExprDef,
  FieldExprDef,
  FieldNamedDef,
  MathExpr,
  NameExpr,
  NegateExpr,
  NumberExpr,
  type Expression,
  type FieldDefinition,
} from "@ton-community/tlb-parser";

import type {
  AbiField,
  AbiGetMethod,
  AbiInterface,
  AbiMessage,
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
  diagnostics: string[];
}

type TlbSourceKind = "message" | "type";

interface ParsedTlbDeclaration {
  sourceKind: TlbSourceKind;
  sourceName: string;
  tlb: string;
  constructorName: string;
  resultType: string;
  prefix?: string;
  fields: ParsedTlbField[];
}

interface ParsedTlbField {
  name?: string;
  type: ParsedTlbType;
}

type ParsedTlbType =
  | { kind: "address" }
  | { kind: "anonymous"; isRef: boolean; fields: ParsedTlbField[] }
  | { kind: "bits"; bits?: number }
  | { kind: "bool" }
  | { kind: "cell" }
  | { kind: "coins" }
  | { kind: "conditional"; inner: ParsedTlbType }
  | { kind: "either"; left: ParsedTlbType; right: ParsedTlbType }
  | { kind: "map"; keyBits?: number; value: ParsedTlbType }
  | { kind: "maybe"; inner: ParsedTlbType }
  | { kind: "multiple"; inner: ParsedTlbType }
  | { kind: "named"; name: string; args: ParsedTlbType[] }
  | { kind: "number"; signed: boolean; bits?: number }
  | { kind: "numberExpr"; value?: number }
  | { kind: "ref"; inner: ParsedTlbType }
  | { kind: "tuple" }
  | { kind: "unknown" }
  | { kind: "varint"; signed: boolean; size?: number };

interface TlbStructPlan {
  declaration: ParsedTlbDeclaration;
  structName: string;
}

interface TlbAliasPlan {
  aliasName: string;
  variants: string[];
}

interface KnownTlbTypeInfo {
  tolkName: string;
  declarations: ParsedTlbDeclaration[];
}

interface MessageRenderPlan {
  incomingMessagesHeaderType?: string;
  incomingExternalHeaderType?: string;
  outgoingMessagesHeaderType?: string;
  incomingMessagesType?: string;
  incomingExternalType?: string;
  outgoingMessagesType?: string;
  jettonPayloadType?: string;
  nftPayloadType?: string;
  forceAbiExportTypes: string[];
  knownTypes: Map<string, string>;
  knownTypeInfo: Map<string, KnownTlbTypeInfo>;
  typeStructs: TlbStructPlan[];
  typeAliases: TlbAliasPlan[];
  messageStructs: TlbStructPlan[];
  messageAliases: TlbAliasPlan[];
  diagnostics: string[];
}

interface ParsedSchemaTlb {
  messageByKey: Map<string, ParsedTlbDeclaration>;
  typeDeclarations: ParsedTlbDeclaration[];
  diagnostics: string[];
}

interface RenderedTolkTypes {
  source: string;
  diagnostics: string[];
}

const parsedSchemaTlbCache = new WeakMap<AbiSchema, ParsedSchemaTlb>();

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
    const schemaLevelRefs = createSchemaLevelMessageReferences(schema.messages);
    const rendered = renderTolkTypes({
      schema,
      contractName: toPascalCase(schema.schemaId),
      methods: schema.getMethods,
      errors: [],
      msgIn: schemaLevelRefs.msgIn,
      msgOut: schemaLevelRefs.msgOut,
      payloads: schemaLevelRefs.payloads,
      codeHashes: [],
    });
    return [
      {
        schemaId: schema.schemaId,
        fileName,
        path: path.join(outDir, fileName),
        source: rendered.source,
        diagnostics: rendered.diagnostics,
      },
    ];
  }

  return schema.interfaces.map((abiInterface) => {
    const resolved = resolveInterface(schema, abiInterface);
    const fileName = `${safeFileStem(abiInterface.name)}.types.tolk`;
    const rendered = renderTolkTypes({
      schema,
      contractName: toPascalCase(abiInterface.name),
      methods: resolveInterfaceGetMethods(schema, resolved.getMethods),
      errors: resolved.errors,
      msgIn: resolved.msgIn,
      msgOut: resolved.msgOut,
      payloads: [],
      codeHashes: resolved.codeHashes,
    });

    return {
      schemaId: schema.schemaId,
      interfaceName: abiInterface.name,
      fileName,
      path: path.join(outDir, fileName),
      source: rendered.source,
      diagnostics: rendered.diagnostics,
    };
  });
}

function createSchemaLevelMessageReferences(messages: AbiMessage[]): {
  msgIn: AbiMessageReference[];
  msgOut: AbiMessageReference[];
  payloads: AbiMessage[];
} {
  const msgIn: AbiMessageReference[] = [];
  const msgOut: AbiMessageReference[] = [];
  const payloads: AbiMessage[] = [];

  for (const message of messages) {
    if (message.kind === "internal" || message.kind === "ext_in") {
      msgIn.push({
        kind: message.kind,
        name: message.name,
        attributes: message.attributes,
      });
    } else if (message.kind === "ext_out") {
      msgOut.push({
        kind: message.kind,
        name: message.name,
        attributes: message.attributes,
      });
    } else if (message.kind === "jetton_payload" || message.kind === "nft_payload") {
      payloads.push(message);
    }
  }

  return { msgIn, msgOut, payloads };
}

interface RenderTolkParams {
  schema: AbiSchema;
  contractName: string;
  methods: AbiGetMethod[];
  errors: AbiInterface["errors"];
  msgIn: AbiMessageReference[];
  msgOut: AbiMessageReference[];
  payloads: AbiMessage[];
  codeHashes: string[];
}

function renderTolkTypes(params: RenderTolkParams): RenderedTolkTypes {
  const ctx: RenderContext = {
    declarations: [],
    usedTypeNames: new Set(),
  };
  const messagePlan = createMessageRenderPlan(
    ctx,
    params.schema,
    params.contractName,
    params.msgIn,
    params.msgOut,
    params.payloads,
  );

  const header: string[] = [];
  const body: string[] = [];

  header.push("// Generated from XML ABI schemas.");
  header.push(`// Source schema: schemas/${params.schema.fileName}`);
  header.push("// TL-B message bodies are generated from @ton-community/tlb-parser.");
  for (const codeHash of unique(params.codeHashes)) {
    header.push(`// Code hash: ${codeHash}`);
  }
  header.push("");
  header.push(`contract ${params.contractName} {`);
  header.push(`    author: "Generated from ABI XML"`);
  header.push(`    version: "0.1"`);
  header.push(
    `    description: "Generated interface for schemas/${escapeTolkString(
      params.schema.fileName,
    )}"`,
  );
  if (messagePlan.incomingMessagesHeaderType) {
    header.push(`    incomingMessages: ${messagePlan.incomingMessagesHeaderType}`);
  }
  if (messagePlan.incomingExternalHeaderType) {
    header.push(`    incomingExternal: ${messagePlan.incomingExternalHeaderType}`);
  }
  if (messagePlan.outgoingMessagesHeaderType) {
    header.push(`    outgoingMessages: ${messagePlan.outgoingMessagesHeaderType}`);
  }
  if (messagePlan.forceAbiExportTypes.length > 0) {
    header.push(`    forceAbiExport: ${messagePlan.forceAbiExportTypes.join(" | ")}`);
  }
  header.push(`}`);
  header.push("");

  ctx.declarations.push(...renderMessagePlan(ctx, messagePlan));

  const errorEnum = renderErrorsEnum(params.errors);
  if (errorEnum.length > 0) {
    body.push(...errorEnum, "");
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

  const source =
    normalizeTopLevelSpacing([...header, ...ctx.declarations, ...body])
      .join("\n")
      .trimEnd() + "\n";
  return { source, diagnostics: unique(messagePlan.diagnostics) };
}

interface RenderContext {
  declarations: string[];
  usedTypeNames: Set<string>;
}

function createMessageRenderPlan(
  ctx: RenderContext,
  schema: AbiSchema,
  contractName: string,
  msgIn: AbiMessageReference[],
  msgOut: AbiMessageReference[],
  payloads: AbiMessage[],
): MessageRenderPlan {
  const parsedSchema = getParsedSchemaTlb(schema);
  const diagnostics = [...parsedSchema.diagnostics];
  const messageByKey = parsedSchema.messageByKey;
  const typeDeclarations = parsedSchema.typeDeclarations;

  const typeDeclarationsByResult = groupDeclarationsByResultType(typeDeclarations);
  const incomingInternal = resolveMessageReferences(
    messageByKey,
    msgIn.filter((ref) => ref.kind === "internal"),
  );
  const incomingExternal = resolveMessageReferences(
    messageByKey,
    msgIn.filter((ref) => ref.kind === "ext_in"),
  );
  const outgoing = resolveMessageReferences(messageByKey, msgOut);
  const jettonPayloads = resolvePayloadMessages(
    messageByKey,
    payloads.filter((message) => message.kind === "jetton_payload"),
  );
  const nftPayloads = resolvePayloadMessages(
    messageByKey,
    payloads.filter((message) => message.kind === "nft_payload"),
  );
  const selectedMessages = uniqueDeclarations([
    ...incomingInternal,
    ...incomingExternal,
    ...outgoing,
    ...jettonPayloads,
    ...nftPayloads,
  ]);

  const neededTypeNames = new Set<string>();
  for (const message of selectedMessages) {
    collectReferencedTlbTypeNamesFromFields(message.fields, neededTypeNames);
  }

  const selectedTypeDeclarations: ParsedTlbDeclaration[] = [];
  const selectedTypeKeys = new Set<string>();
  const processedTypeNames = new Set<string>();
  const pendingTypeNames = [...neededTypeNames];
  while (pendingTypeNames.length > 0) {
    const typeName = pendingTypeNames.shift();
    if (!typeName || processedTypeNames.has(typeName)) {
      continue;
    }
    processedTypeNames.add(typeName);

    const declarations = typeDeclarationsByResult.get(typeName) ?? [];
    for (const declaration of declarations) {
      const key = declarationIdentity(declaration);
      if (selectedTypeKeys.has(key)) {
        continue;
      }

      selectedTypeKeys.add(key);
      selectedTypeDeclarations.push(declaration);

      const childTypeNames = new Set<string>();
      collectReferencedTlbTypeNamesFromFields(declaration.fields, childTypeNames);
      for (const childTypeName of childTypeNames) {
        if (!processedTypeNames.has(childTypeName)) {
          pendingTypeNames.push(childTypeName);
        }
      }
    }
  }

  const knownTypes = new Map<string, string>();
  const knownTypeInfo = new Map<string, KnownTlbTypeInfo>();
  const typeStructs: TlbStructPlan[] = [];
  const typeAliases: TlbAliasPlan[] = [];
  const typeGroups = groupDeclarationsByResultType(selectedTypeDeclarations);
  for (const [resultType, declarations] of typeGroups) {
    const aliasName = uniqueTypeName(ctx, toPascalCase(resultType));
    knownTypeInfo.set(resultType, { tolkName: aliasName, declarations });
    if (declarations.length === 1) {
      knownTypes.set(resultType, aliasName);
    }

    const variants: string[] = [];
    declarations.forEach((declaration, index) => {
      const structName =
        declarations.length === 1 && shouldUseResultTypeAsStructName(declaration)
          ? aliasName
          : uniqueTypeName(
              ctx,
              toPascalCase(
                declaration.constructorName === "_"
                  ? `${resultType}_${index + 1}`
                  : declaration.constructorName,
              ),
            );

      typeStructs.push({ declaration, structName });
      variants.push(structName);
    });

    if (!(variants.length === 1 && variants[0] === aliasName)) {
      typeAliases.push({ aliasName, variants });
    }
  }

  const messageStructs = selectedMessages.map((declaration) => ({
    declaration,
    structName: uniqueTypeName(ctx, toPascalCase(declaration.sourceName)),
  }));
  const messageStructNameByKey = new Map(
    messageStructs.map((item) => [declarationIdentity(item.declaration), item.structName]),
  );

  const messageAliases: TlbAliasPlan[] = [];
  const incomingMessagesType = addMessageAlias(
    ctx,
    messageAliases,
    `${contractName}IncomingMessage`,
    incomingInternal,
    messageStructNameByKey,
  );
  const incomingExternalType = addMessageAlias(
    ctx,
    messageAliases,
    `${contractName}IncomingExternalMessage`,
    incomingExternal,
    messageStructNameByKey,
  );
  const outgoingMessagesType = addMessageAlias(
    ctx,
    messageAliases,
    `${contractName}OutgoingMessage`,
    outgoing,
    messageStructNameByKey,
  );
  const jettonPayloadType = addMessageAlias(
    ctx,
    messageAliases,
    `${contractName}JettonPayload`,
    jettonPayloads,
    messageStructNameByKey,
  );
  const nftPayloadType = addMessageAlias(
    ctx,
    messageAliases,
    `${contractName}NftPayload`,
    nftPayloads,
    messageStructNameByKey,
  );
  const incomingMessagesHeaderType = headerTypeIfSerializable(
    incomingMessagesType,
    incomingInternal,
    "incomingMessages",
    diagnostics,
  );
  const incomingExternalHeaderType = headerTypeIfSerializable(
    incomingExternalType,
    incomingExternal,
    "incomingExternal",
    diagnostics,
  );
  const outgoingMessagesHeaderType = headerTypeIfSerializable(
    outgoingMessagesType,
    outgoing,
    "outgoingMessages",
    diagnostics,
  );
  const forceAbiExportTypes = collectForceAbiExportTypes({
    incomingMessagesType,
    incomingMessagesHeaderType,
    incomingExternalType,
    incomingExternalHeaderType,
    outgoingMessagesType,
    outgoingMessagesHeaderType,
    jettonPayloadType,
    nftPayloadType,
  });

  return {
    ...(incomingMessagesHeaderType ? { incomingMessagesHeaderType } : {}),
    ...(incomingExternalHeaderType ? { incomingExternalHeaderType } : {}),
    ...(outgoingMessagesHeaderType ? { outgoingMessagesHeaderType } : {}),
    ...(incomingMessagesType ? { incomingMessagesType } : {}),
    ...(incomingExternalType ? { incomingExternalType } : {}),
    ...(outgoingMessagesType ? { outgoingMessagesType } : {}),
    ...(jettonPayloadType ? { jettonPayloadType } : {}),
    ...(nftPayloadType ? { nftPayloadType } : {}),
    forceAbiExportTypes,
    knownTypes,
    knownTypeInfo,
    typeStructs,
    typeAliases,
    messageStructs,
    messageAliases,
    diagnostics,
  };
}

function getParsedSchemaTlb(schema: AbiSchema): ParsedSchemaTlb {
  const cached = parsedSchemaTlbCache.get(schema);
  if (cached) {
    return cached;
  }

  const diagnostics: string[] = [];
  const messageByKey = new Map<string, ParsedTlbDeclaration>();
  for (const message of schema.messages) {
    const parsed = parseTlbDeclaration(
      message.tlb,
      "message",
      message.name,
      diagnostics,
    );
    if (parsed) {
      messageByKey.set(messageKey(message.kind, message.name), parsed);
    }
  }

  const typeDeclarations = schema.types
    .map((typeDefinition, index) =>
      parseTlbDeclaration(
        typeDefinition.tlb,
        "type",
        `type_${index + 1}`,
        diagnostics,
      ),
    )
    .filter((declaration): declaration is ParsedTlbDeclaration => declaration !== undefined);

  const result = { messageByKey, typeDeclarations, diagnostics };
  parsedSchemaTlbCache.set(schema, result);
  return result;
}

function renderMessagePlan(ctx: RenderContext, plan: MessageRenderPlan): string[] {
  const lines: string[] = [];

  if (plan.diagnostics.length > 0) {
    lines.push("// TL-B parser notes:");
    for (const diagnostic of unique(plan.diagnostics)) {
      lines.push(`// - ${diagnostic}`);
    }
    lines.push("");
  }

  if (plan.typeStructs.length > 0) {
    lines.push("// TL-B helper types referenced by messages.");
    for (const item of plan.typeStructs) {
      lines.push(...renderTlbStruct(ctx, item, plan.knownTypes), "");
    }
    for (const alias of plan.typeAliases) {
      lines.push(...renderTypeAlias(alias), "");
    }
  }

  if (plan.messageStructs.length > 0) {
    lines.push("// TL-B message bodies.");
    for (const item of plan.messageStructs) {
      lines.push(...renderTlbStruct(ctx, item, plan.knownTypes), "");
    }
  }

  if (plan.messageAliases.length > 0) {
    lines.push("// Message unions used by Acton ABI.");
    for (const alias of plan.messageAliases) {
      lines.push(...renderTypeAlias(alias), "");
    }
  }

  return trimTrailingEmptyLines(lines);
}

function addMessageAlias(
  ctx: RenderContext,
  aliases: TlbAliasPlan[],
  preferredName: string,
  declarations: ParsedTlbDeclaration[],
  structNameByKey: Map<string, string>,
): string | undefined {
  const variants = unique(
    declarations
      .map((declaration) => structNameByKey.get(declarationIdentity(declaration)))
      .filter((name): name is string => name !== undefined),
  );
  if (variants.length === 0) {
    return undefined;
  }

  const aliasName = uniqueTypeName(ctx, preferredName);
  aliases.push({ aliasName, variants });
  return aliasName;
}

function headerTypeIfSerializable(
  aliasName: string | undefined,
  declarations: ParsedTlbDeclaration[],
  headerField: string,
  diagnostics: string[],
): string | undefined {
  if (!aliasName || declarations.length === 0) {
    return undefined;
  }

  const problem = messageHeaderSerializationProblem(declarations);
  if (!problem) {
    return aliasName;
  }

  diagnostics.push(
    `${headerField}: not added to contract header because ${problem}; the message structs and union type are still generated.`,
  );
  return undefined;
}

function messageHeaderSerializationProblem(
  declarations: ParsedTlbDeclaration[],
): string | undefined {
  if (declarations.length <= 1) {
    return undefined;
  }

  const prefixes = new Map<string, string>();
  for (const declaration of declarations) {
    if (!declaration.prefix) {
      return `${declaration.sourceName} has no opcode prefix`;
    }

    const existing = prefixes.get(declaration.prefix);
    if (existing) {
      return `${existing} and ${declaration.sourceName} share opcode ${declaration.prefix}`;
    }
    prefixes.set(declaration.prefix, declaration.sourceName);
  }

  return undefined;
}

function resolveMessageReferences(
  messageByKey: Map<string, ParsedTlbDeclaration>,
  refs: AbiMessageReference[],
): ParsedTlbDeclaration[] {
  return uniqueDeclarations(
    refs
      .map((ref) => messageByKey.get(messageKey(ref.kind, ref.name)))
      .filter((declaration): declaration is ParsedTlbDeclaration => declaration !== undefined),
  );
}

function resolvePayloadMessages(
  messageByKey: Map<string, ParsedTlbDeclaration>,
  messages: AbiMessage[],
): ParsedTlbDeclaration[] {
  return uniqueDeclarations(
    messages
      .map((message) => messageByKey.get(messageKey(message.kind, message.name)))
      .filter((declaration): declaration is ParsedTlbDeclaration => declaration !== undefined),
  );
}

function collectForceAbiExportTypes(types: {
  incomingMessagesType: string | undefined;
  incomingMessagesHeaderType: string | undefined;
  incomingExternalType: string | undefined;
  incomingExternalHeaderType: string | undefined;
  outgoingMessagesType: string | undefined;
  outgoingMessagesHeaderType: string | undefined;
  jettonPayloadType: string | undefined;
  nftPayloadType: string | undefined;
}): string[] {
  const result: string[] = [];

  if (types.incomingMessagesType && !types.incomingMessagesHeaderType) {
    result.push(types.incomingMessagesType);
  }
  if (types.incomingExternalType && !types.incomingExternalHeaderType) {
    result.push(types.incomingExternalType);
  }
  if (types.outgoingMessagesType && !types.outgoingMessagesHeaderType) {
    result.push(types.outgoingMessagesType);
  }
  if (types.jettonPayloadType) {
    result.push(types.jettonPayloadType);
  }
  if (types.nftPayloadType) {
    result.push(types.nftPayloadType);
  }

  return unique(result);
}

function messageKey(kind: AbiMessage["kind"], name: string): string {
  return `${kind}:${name}`;
}

function groupDeclarationsByResultType(
  declarations: ParsedTlbDeclaration[],
): Map<string, ParsedTlbDeclaration[]> {
  const result = new Map<string, ParsedTlbDeclaration[]>();
  for (const declaration of declarations) {
    const items = result.get(declaration.resultType) ?? [];
    items.push(declaration);
    result.set(declaration.resultType, items);
  }
  return result;
}

function uniqueDeclarations(
  declarations: ParsedTlbDeclaration[],
): ParsedTlbDeclaration[] {
  const seen = new Set<string>();
  const result: ParsedTlbDeclaration[] = [];
  for (const declaration of declarations) {
    const key = declarationIdentity(declaration);
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    result.push(declaration);
  }
  return result;
}

function declarationIdentity(declaration: ParsedTlbDeclaration): string {
  return `${declaration.sourceKind}:${declaration.sourceName}:${declaration.tlb}`;
}

function shouldUseResultTypeAsStructName(declaration: ParsedTlbDeclaration): boolean {
  return (
    declaration.constructorName === "_" ||
    toPascalCase(declaration.constructorName) === toPascalCase(declaration.resultType)
  );
}

function parseTlbDeclaration(
  tlb: string,
  sourceKind: TlbSourceKind,
  sourceName: string,
  diagnostics: string[],
): ParsedTlbDeclaration | undefined {
  try {
    const program = parseTlbAst(tlb);
    const [declaration] = program.declarations;
    if (!declaration) {
      diagnostics.push(`${sourceName}: TL-B declaration is empty.`);
      return undefined;
    }

    const prefix = formatTlbPrefix(declaration.constructorDef.tag);
    return {
      sourceKind,
      sourceName,
      tlb,
      constructorName: declaration.constructorDef.name,
      resultType: declaration.combinator.name,
      ...(prefix !== undefined ? { prefix } : {}),
      fields: parseTlbFields(declaration.fields),
    };
  } catch (error) {
    const fallback = parseFallbackTlbDeclaration(tlb, sourceKind, sourceName);
    if (fallback) {
      diagnostics.push(
        `${sourceName}: parsed with a fallback for TL-B constructs not accepted by @ton-community/tlb-parser (${formatErrorMessage(
          error,
        )}).`,
      );
      return fallback;
    }

    diagnostics.push(
      `${sourceName}: skipped, @ton-community/tlb-parser could not parse it (${formatErrorMessage(
        error,
      )}).`,
    );
    return undefined;
  }
}

function parseTlbFields(fields: FieldDefinition[]): ParsedTlbField[] {
  const result: ParsedTlbField[] = [];
  for (const field of fields) {
    if (field instanceof FieldNamedDef) {
      result.push({
        name: field.name,
        type: parseTlbTypeExpression(field.expr),
      });
      continue;
    }

    if (field instanceof FieldAnonymousDef) {
      result.push({
        ...(field.name ? { name: field.name } : {}),
        type: {
          kind: "anonymous",
          isRef: field.isRef,
          fields: parseTlbFields(field.fields),
        },
      });
      continue;
    }

    if (field instanceof FieldExprDef) {
      result.push({ type: parseTlbTypeExpression(field.expr) });
      continue;
    }

    if (
      field instanceof FieldBuiltinDef ||
      field instanceof FieldCurlyExprDef
    ) {
      continue;
    }
  }
  return result;
}

function parseTlbTypeExpression(expr: Expression): ParsedTlbType {
  if (expr instanceof NameExpr) {
    return parseTlbNameType(expr.name);
  }

  if (expr instanceof NumberExpr) {
    return { kind: "numberExpr", value: expr.num };
  }

  if (expr instanceof BuiltinZeroArgs) {
    return expr.name === "#" ? { kind: "number", signed: false, bits: 32 } : { kind: "unknown" };
  }

  if (expr instanceof BuiltinOneArgExpr) {
    const value = constantExpressionValue(expr.arg);
    if (expr.name === "##") {
      return { kind: "number", signed: false, ...(value !== undefined ? { bits: value } : {}) };
    }
    return { kind: "number", signed: false, bits: 32 };
  }

  if (expr instanceof CellRefExpr) {
    return { kind: "ref", inner: parseTlbTypeExpression(expr.expr) };
  }

  if (expr instanceof CombinatorExpr) {
    return parseTlbCombinatorType(expr);
  }

  if (expr instanceof CondExpr) {
    return { kind: "conditional", inner: parseTlbTypeExpression(expr.condExpr) };
  }

  if (expr instanceof MathExpr) {
    const value = constantExpressionValue(expr);
    return { kind: "numberExpr", ...(value !== undefined ? { value } : {}) };
  }

  if (expr instanceof NegateExpr) {
    return { kind: "unknown" };
  }

  return { kind: "unknown" };
}

function parseTlbCombinatorType(expr: CombinatorExpr): ParsedTlbType {
  const args = expr.args.map((arg) => parseTlbTypeExpression(arg));
  const firstArgValue = expr.args[0] ? constantExpressionValue(expr.args[0]) : undefined;

  switch (expr.name) {
    case "Maybe":
      return { kind: "maybe", inner: args[0] ?? { kind: "unknown" } };
    case "Either":
      return {
        kind: "either",
        left: args[0] ?? { kind: "unknown" },
        right: args[1] ?? { kind: "unknown" },
      };
    case "VarUInteger":
      return {
        kind: "varint",
        signed: false,
        ...(firstArgValue !== undefined ? { size: firstArgValue } : {}),
      };
    case "VarInteger":
      return {
        kind: "varint",
        signed: true,
        ...(firstArgValue !== undefined ? { size: firstArgValue } : {}),
      };
    case "int":
      return {
        kind: "number",
        signed: true,
        ...(firstArgValue !== undefined ? { bits: firstArgValue } : {}),
      };
    case "uint":
      return {
        kind: "number",
        signed: false,
        ...(firstArgValue !== undefined ? { bits: firstArgValue } : {}),
      };
    case "bits":
      return { kind: "bits", ...(firstArgValue !== undefined ? { bits: firstArgValue } : {}) };
    case "Hashmap":
    case "HashmapE":
    case "HashmapAugE":
      return {
        kind: "map",
        ...(firstArgValue !== undefined ? { keyBits: firstArgValue } : {}),
        value: args[1] ?? { kind: "cell" },
      };
    default:
      return { kind: "named", name: expr.name, args };
  }
}

function parseTlbNameType(name: string): ParsedTlbType {
  const normalized = name.trim();
  const lower = normalized.toLowerCase();

  if (lower === "bool" || lower === "boolfalse" || lower === "booltrue") {
    return { kind: "bool" };
  }

  if (lower === "coins" || lower === "grams") {
    return { kind: "coins" };
  }

  if (
    lower === "msgaddress" ||
    lower === "msgaddressint" ||
    lower === "msgaddressext"
  ) {
    return { kind: "address" };
  }

  if (lower === "cell" || lower === "any") {
    return { kind: "cell" };
  }

  if (lower === "bits") {
    return { kind: "bits" };
  }

  if (lower === "bit") {
    return { kind: "bits", bits: 1 };
  }

  if (lower === "int") {
    return { kind: "number", signed: true, bits: 257 };
  }

  if (lower === "uint") {
    return { kind: "number", signed: false, bits: 257 };
  }

  const integerMatch = lower.match(/^(u?int)(\d+)$/u);
  if (integerMatch?.[1] && integerMatch[2]) {
    return {
      kind: "number",
      signed: integerMatch[1] === "int",
      bits: Number.parseInt(integerMatch[2], 10),
    };
  }

  const bitsMatch = lower.match(/^bits(\d+)$/u);
  if (bitsMatch?.[1]) {
    return { kind: "bits", bits: Number.parseInt(bitsMatch[1], 10) };
  }

  if (lower === "vmstack") {
    return { kind: "tuple" };
  }

  return { kind: "named", name: normalized, args: [] };
}

function parseFallbackTlbDeclaration(
  tlb: string,
  sourceKind: TlbSourceKind,
  sourceName: string,
): ParsedTlbDeclaration | undefined {
  const eqIndex = findTopLevelChar(tlb, "=");
  if (eqIndex === -1) {
    return undefined;
  }

  const left = tlb.slice(0, eqIndex).trim();
  const right = tlb.slice(eqIndex + 1).replace(/;$/u, "").trim();
  const [resultType] = right.split(/\s+/u);
  if (!resultType) {
    return undefined;
  }

  const tokens = splitTopLevelTokens(left);
  const [constructorToken, ...fieldTokens] = tokens;
  if (!constructorToken) {
    return undefined;
  }

  const constructor = parseConstructorToken(constructorToken);
  if (!constructor) {
    return undefined;
  }

  const fields = fieldTokens
    .map(parseFallbackTlbField)
    .filter((field): field is ParsedTlbField => field !== undefined);

  const prefix = formatTlbPrefix(constructor.tag);
  return {
    sourceKind,
    sourceName,
    tlb,
    constructorName: constructor.name,
    resultType,
    ...(prefix !== undefined ? { prefix } : {}),
    fields,
  };
}

function parseConstructorToken(token: string): { name: string; tag: string | null } | undefined {
  const match = token.match(/^([A-Za-z_][0-9A-Za-z_]*|_)([#$][0-9A-Fa-f_]+)?$/u);
  if (!match?.[1]) {
    return undefined;
  }
  return {
    name: match[1],
    tag: match[2] ?? null,
  };
}

function parseFallbackTlbField(token: string): ParsedTlbField | undefined {
  const colonIndex = findTopLevelChar(token, ":");
  if (colonIndex === -1) {
    return undefined;
  }

  const name = token.slice(0, colonIndex).trim();
  const rawType = token.slice(colonIndex + 1).trim();
  if (!name || !rawType) {
    return undefined;
  }

  return {
    name,
    type: parseFallbackTlbType(rawType),
  };
}

function parseFallbackTlbType(rawType: string): ParsedTlbType {
  const type = stripOuterParens(rawType.trim());
  if (type.startsWith("Maybe ")) {
    return { kind: "maybe", inner: parseFallbackTlbType(type.slice("Maybe ".length)) };
  }
  if (type.startsWith("Either ")) {
    const args = splitTopLevelTokens(type.slice("Either ".length));
    return {
      kind: "either",
      left: args[0] ? parseFallbackTlbType(args[0]) : { kind: "unknown" },
      right: args[1] ? parseFallbackTlbType(args[1]) : { kind: "unknown" },
    };
  }
  if (type.startsWith("^[")) {
    return {
      kind: "anonymous",
      isRef: true,
      fields: parseFallbackAnonymousFields(type),
    };
  }
  if (type.startsWith("[")) {
    return {
      kind: "anonymous",
      isRef: false,
      fields: parseFallbackAnonymousFields(type),
    };
  }
  if (type.startsWith("^")) {
    return { kind: "ref", inner: parseFallbackTlbType(type.slice(1)) };
  }

  const combinator = type.match(/^([A-Za-z_][0-9A-Za-z_]*|_)\s+(.+)$/u);
  if (combinator?.[1] && combinator[2]) {
    const args = splitTopLevelTokens(combinator[2]).map(parseFallbackTlbType);
    return parseFallbackCombinatorType(combinator[1], args);
  }

  return parseTlbNameType(type);
}

function parseFallbackCombinatorType(
  name: string,
  args: ParsedTlbType[],
): ParsedTlbType {
  const firstNumber = args[0]?.kind === "numberExpr" ? args[0].value : undefined;
  switch (name) {
    case "VarUInteger":
      return {
        kind: "varint",
        signed: false,
        ...(firstNumber !== undefined ? { size: firstNumber } : {}),
      };
    case "VarInteger":
      return {
        kind: "varint",
        signed: true,
        ...(firstNumber !== undefined ? { size: firstNumber } : {}),
      };
    case "Maybe":
      return { kind: "maybe", inner: args[0] ?? { kind: "unknown" } };
    case "Either":
      return {
        kind: "either",
        left: args[0] ?? { kind: "unknown" },
        right: args[1] ?? { kind: "unknown" },
      };
    case "int":
    case "uint":
      return {
        kind: "number",
        signed: name === "int",
        ...(firstNumber !== undefined ? { bits: firstNumber } : {}),
      };
    case "bits":
      return { kind: "bits", ...(firstNumber !== undefined ? { bits: firstNumber } : {}) };
    default:
      return { kind: "named", name, args };
  }
}

function parseFallbackAnonymousFields(rawType: string): ParsedTlbField[] {
  const openIndex = rawType.indexOf("[");
  const closeIndex = findMatchingBracket(rawType, openIndex, "[", "]");
  if (openIndex === -1 || closeIndex === -1) {
    return [];
  }

  return splitTopLevelTokens(rawType.slice(openIndex + 1, closeIndex))
    .map(parseFallbackTlbField)
    .filter((field): field is ParsedTlbField => field !== undefined);
}

function formatTlbPrefix(tag: string | null): string | undefined {
  if (!tag || tag === "#_" || tag === "$_") {
    return undefined;
  }

  if (tag.startsWith("#")) {
    return `0x${tag.slice(1)}`;
  }

  if (tag.startsWith("$")) {
    return `0b${tag.slice(1)}`;
  }

  return undefined;
}

function constantExpressionValue(expr: Expression): number | undefined {
  if (expr instanceof NumberExpr) {
    return expr.num;
  }

  if (expr instanceof MathExpr) {
    const left = constantExpressionValue(expr.left);
    const right = constantExpressionValue(expr.right);
    if (left === undefined || right === undefined) {
      return undefined;
    }

    if (expr.op === "+") {
      return left + right;
    }
    if (expr.op === "*") {
      return left * right;
    }
  }

  return undefined;
}

function collectReferencedTlbTypeNamesFromFields(
  fields: ParsedTlbField[],
  result: Set<string>,
): void {
  for (const field of fields) {
    collectReferencedTlbTypeNames(field.type, result);
  }
}

function collectReferencedTlbTypeNames(type: ParsedTlbType, result: Set<string>): void {
  switch (type.kind) {
    case "anonymous":
      collectReferencedTlbTypeNamesFromFields(type.fields, result);
      break;
    case "conditional":
    case "maybe":
    case "multiple":
    case "ref":
      collectReferencedTlbTypeNames(type.inner, result);
      break;
    case "either":
      collectReferencedTlbTypeNames(type.left, result);
      collectReferencedTlbTypeNames(type.right, result);
      break;
    case "map":
      collectReferencedTlbTypeNames(type.value, result);
      break;
    case "named":
      if (!isBuiltinTlbNamedType(type.name)) {
        result.add(type.name);
      }
      for (const arg of type.args) {
        collectReferencedTlbTypeNames(arg, result);
      }
      break;
    default:
      break;
  }
}

function isBuiltinTlbNamedType(name: string): boolean {
  const lower = name.toLowerCase();
  return (
    lower === "maybe" ||
    lower === "either" ||
    lower === "bool" ||
    lower === "boolfalse" ||
    lower === "booltrue" ||
    lower === "cell" ||
    lower === "any" ||
    lower === "coins" ||
    lower === "grams" ||
    lower === "text" ||
    lower === "bytes" ||
    lower === "bits" ||
    lower === "bit" ||
    lower === "int" ||
    lower === "uint" ||
    lower === "msgaddress" ||
    lower === "msgaddressint" ||
    lower === "msgaddressext" ||
    lower === "stateinit" ||
    lower === "currencycollection"
  );
}

function renderTlbStruct(
  ctx: RenderContext,
  item: TlbStructPlan,
  knownTypes: Map<string, string>,
): string[] {
  const prefix = item.declaration.prefix ? ` (${item.declaration.prefix})` : "";
  const fields = createNamedTlbFields(item.declaration.fields, "field");

  if (fields.length === 0) {
    return [`struct${prefix} ${item.structName} {}`];
  }

  const lines = [`struct${prefix} ${item.structName} {`];
  for (const field of fields) {
    lines.push(
      `    ${field.name}: ${renderTlbType(
        ctx,
        field.field.type,
        knownTypes,
        item.structName,
        field.name,
      )}`,
    );
  }
  lines.push("}");
  return lines;
}

function renderTypeAlias(alias: TlbAliasPlan): string[] {
  if (alias.variants.length === 0) {
    return [];
  }

  if (alias.variants.length === 1) {
    return [`type ${alias.aliasName} = ${alias.variants[0]}`];
  }

  return [
    `type ${alias.aliasName} =`,
    ...alias.variants.map((variant) => `    | ${variant}`),
  ];
}

function renderTlbType(
  ctx: RenderContext,
  type: ParsedTlbType,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  switch (type.kind) {
    case "address":
      return "address";
    case "anonymous":
      return renderAnonymousTlbType(ctx, type, knownTypes, ownerName, fieldName);
    case "bits":
      return type.bits !== undefined ? `bits${type.bits}` : "RemainingBitsAndRefs";
    case "bool":
      return "bool";
    case "cell":
      return "cell";
    case "coins":
      return "coins";
    case "conditional":
      return `${renderTlbType(ctx, type.inner, knownTypes, ownerName, fieldName)}?`;
    case "either":
      return "RemainingBitsAndRefs";
    case "map":
      return `map<uint${type.keyBits ?? 256}, ${renderMapValueType(
        ctx,
        type.value,
        knownTypes,
        ownerName,
        fieldName,
      )}>`;
    case "maybe":
      return `${renderMaybeTlbType(ctx, type.inner, knownTypes, ownerName, fieldName)}?`;
    case "multiple":
      return "cell";
    case "named":
      return renderNamedTlbType(ctx, type, knownTypes, ownerName, fieldName);
    case "number":
      return renderIntegerTlbType(type.signed, type.bits);
    case "numberExpr":
      return type.value !== undefined ? `uint${type.value}` : "int";
    case "ref":
      return renderRefTlbType(ctx, type.inner, knownTypes, ownerName, fieldName);
    case "tuple":
      return "tuple";
    case "unknown":
      return "cell";
    case "varint":
      return type.signed ? "int" : "coins";
  }
}

function renderMapValueType(
  ctx: RenderContext,
  type: ParsedTlbType,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  const rendered = renderTlbType(ctx, type, knownTypes, ownerName, fieldName);
  return rendered === "RemainingBitsAndRefs" ? "cell" : rendered;
}

function renderMaybeTlbType(
  ctx: RenderContext,
  type: ParsedTlbType,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  if (type.kind === "ref") {
    return renderRefTlbType(ctx, type.inner, knownTypes, ownerName, fieldName);
  }
  if (type.kind === "anonymous") {
    return renderAnonymousTlbType(ctx, type, knownTypes, ownerName, fieldName);
  }
  return renderTlbType(ctx, type, knownTypes, ownerName, fieldName);
}

function renderRefTlbType(
  ctx: RenderContext,
  inner: ParsedTlbType,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  if (inner.kind === "cell") {
    return "cell";
  }
  if (inner.kind === "anonymous") {
    return renderAnonymousTlbType(
      ctx,
      { ...inner, isRef: true },
      knownTypes,
      ownerName,
      fieldName,
    );
  }

  const innerType = renderTlbType(ctx, inner, knownTypes, ownerName, fieldName);
  return innerType === "cell" ? "cell" : `Cell<${innerType}>`;
}

function renderAnonymousTlbType(
  ctx: RenderContext,
  type: Extract<ParsedTlbType, { kind: "anonymous" }>,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  if (type.fields.length === 0) {
    return type.isRef ? "cell" : "RemainingBitsAndRefs";
  }

  const nestedName = uniqueTypeName(ctx, `${ownerName}${toPascalCase(fieldName)}`);
  ctx.declarations.push(
    ...renderTlbStruct(
      ctx,
      {
        declaration: {
          sourceKind: "type",
          sourceName: nestedName,
          tlb: "",
          constructorName: "_",
          resultType: nestedName,
          fields: type.fields,
        },
        structName: nestedName,
      },
      knownTypes,
    ),
    "",
  );

  return type.isRef ? `Cell<${nestedName}>` : nestedName;
}

function renderNamedTlbType(
  ctx: RenderContext,
  type: Extract<ParsedTlbType, { kind: "named" }>,
  knownTypes: Map<string, string>,
  ownerName: string,
  fieldName: string,
): string {
  const lower = type.name.toLowerCase();
  if (lower === "maybe") {
    return `${renderMaybeTlbType(
      ctx,
      type.args[0] ?? { kind: "unknown" },
      knownTypes,
      ownerName,
      fieldName,
    )}?`;
  }
  if (lower === "either") {
    return "RemainingBitsAndRefs";
  }
  if (lower === "bool" || lower === "boolfalse" || lower === "booltrue") {
    return "bool";
  }
  if (lower === "coins" || lower === "grams") {
    return "coins";
  }
  if (
    lower === "msgaddress" ||
    lower === "msgaddressint" ||
    lower === "msgaddressext"
  ) {
    return "address";
  }
  if (lower === "cell" || lower === "any") {
    return "cell";
  }
  if (lower === "text") {
    return "string";
  }
  if (lower === "bytes") {
    return "RemainingBitsAndRefs";
  }
  if (lower === "stateinit") {
    return "StateInit";
  }
  if (lower === "currencycollection") {
    return "(coins, ExtraCurrenciesMap)";
  }

  const knownType = knownTypes.get(type.name);
  if (knownType) {
    return knownType;
  }

  return "cell";
}

function renderIntegerTlbType(signed: boolean, bits: number | undefined): string {
  if (bits === undefined) {
    return signed ? "int" : "int";
  }

  if (signed && bits >= 257) {
    return "int";
  }

  if (!signed && bits > 256) {
    return "int";
  }

  return `${signed ? "int" : "uint"}${bits}`;
}

interface NamedTlbField {
  name: string;
  field: ParsedTlbField;
}

function createNamedTlbFields(
  fields: ParsedTlbField[],
  fallbackPrefix: string,
): NamedTlbField[] {
  const used = new Set<string>();

  return fields.map((field, index) => {
    const baseName =
      field.name && field.name !== "_"
        ? toCamelCase(field.name)
        : `${fallbackPrefix}${index + 1}`;
    return {
      name: uniqueTolkFieldName(baseName || `${fallbackPrefix}${index + 1}`, used),
      field,
    };
  });
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
  if (ctx.declarations.length > 0 && ctx.declarations.at(-1) !== "") {
    ctx.declarations.push("");
  }

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
      name: uniqueTolkFieldName(baseName || `${fallbackPrefix}${index + 1}`, used),
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

const TOLK_RESERVED_WORDS = new Set([
  "as",
  "assert",
  "break",
  "catch",
  "const",
  "continue",
  "do",
  "else",
  "enum",
  "false",
  "fun",
  "if",
  "import",
  "in",
  "is",
  "lazy",
  "match",
  "mutate",
  "null",
  "private",
  "public",
  "readonly",
  "repeat",
  "return",
  "struct",
  "throw",
  "true",
  "try",
  "type",
  "val",
  "var",
  "void",
  "while",
]);

function uniqueTolkFieldName(preferred: string, used: Set<string>): string {
  const sanitized = sanitizeIdentifier(preferred);
  const base =
    sanitized && TOLK_RESERVED_WORDS.has(sanitized)
      ? `${sanitized}Value`
      : sanitized;
  return uniqueName(base || "field", used);
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

function splitTopLevelTokens(value: string): string[] {
  const tokens: string[] = [];
  let current = "";
  let parens = 0;
  let brackets = 0;
  let braces = 0;

  for (const char of value) {
    if (char === "(") {
      parens += 1;
    } else if (char === ")") {
      parens -= 1;
    } else if (char === "[") {
      brackets += 1;
    } else if (char === "]") {
      brackets -= 1;
    } else if (char === "{") {
      braces += 1;
    } else if (char === "}") {
      braces -= 1;
    }

    if (/\s/u.test(char) && parens === 0 && brackets === 0 && braces === 0) {
      if (current.trim()) {
        tokens.push(current.trim());
      }
      current = "";
      continue;
    }

    current += char;
  }

  if (current.trim()) {
    tokens.push(current.trim());
  }
  return tokens;
}

function findTopLevelChar(value: string, needle: string): number {
  let parens = 0;
  let brackets = 0;
  let braces = 0;

  for (let index = 0; index < value.length; index += 1) {
    const char = value[index];
    if (char === "(") {
      parens += 1;
    } else if (char === ")") {
      parens -= 1;
    } else if (char === "[") {
      brackets += 1;
    } else if (char === "]") {
      brackets -= 1;
    } else if (char === "{") {
      braces += 1;
    } else if (char === "}") {
      braces -= 1;
    } else if (char === needle && parens === 0 && brackets === 0 && braces === 0) {
      return index;
    }
  }

  return -1;
}

function findMatchingBracket(
  value: string,
  openIndex: number,
  open: string,
  close: string,
): number {
  if (openIndex < 0 || value[openIndex] !== open) {
    return -1;
  }

  let depth = 0;
  for (let index = openIndex; index < value.length; index += 1) {
    const char = value[index];
    if (char === open) {
      depth += 1;
    } else if (char === close) {
      depth -= 1;
      if (depth === 0) {
        return index;
      }
    }
  }

  return -1;
}

function stripOuterParens(value: string): string {
  let current = value.trim();
  while (current.startsWith("(") && findMatchingBracket(current, 0, "(", ")") === current.length - 1) {
    current = current.slice(1, -1).trim();
  }
  return current;
}

function trimTrailingEmptyLines(lines: string[]): string[] {
  const result = [...lines];
  while (result.at(-1) === "") {
    result.pop();
  }
  return result;
}

function normalizeTopLevelSpacing(lines: string[]): string[] {
  const normalized: string[] = [];

  for (const line of lines) {
    if (
      startsTopLevelDeclaration(line) &&
      normalized.length > 0 &&
      normalized.at(-1) !== "" &&
      !normalized.at(-1)?.startsWith("// ")
    ) {
      normalized.push("");
    }
    normalized.push(line);
  }

  return normalized;
}

function startsTopLevelDeclaration(line: string): boolean {
  return /^(contract|enum|struct|type|get fun)\b/u.test(line);
}

function formatErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
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
