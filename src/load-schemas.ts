import { readFile, readdir } from "node:fs/promises";
import path from "node:path";

import { parseXmlDocument, type XmlElementNode, type XmlNode } from "./xml.js";
import type {
  AbiError,
  AbiField,
  AbiFieldList,
  AbiGetMethod,
  AbiInterface,
  AbiMessage,
  AbiMessageKind,
  AbiMessageReference,
  AbiMethodReference,
  AbiRegistry,
  AbiSchema,
  AbiTypeDefinition,
} from "./types.js";

const MESSAGE_TAGS = new Set<AbiMessageKind>([
  "internal",
  "ext_in",
  "ext_out",
  "jetton_payload",
  "nft_payload",
]);

export async function loadAbiRegistry(
  schemasDir = path.resolve(process.cwd(), "schemas"),
): Promise<AbiRegistry> {
  const fileNames = (await readdir(schemasDir))
    .filter((fileName) => fileName.endsWith(".xml"))
    .sort((left, right) => left.localeCompare(right));

  const schemas = await Promise.all(
    fileNames.map(async (fileName) => {
      const schemaPath = path.join(schemasDir, fileName);
      const source = await readFile(schemaPath, "utf8");
      return parseAbiSchema({
        fileName,
        schemaPath,
        source,
      });
    }),
  );

  return { schemas };
}

interface ParseSchemaParams {
  fileName: string;
  schemaPath: string;
  source: string;
}

function parseAbiSchema(params: ParseSchemaParams): AbiSchema {
  const root = parseXmlDocument(params.source);
  if (root.name !== "abi") {
    throw new Error(`Expected <abi> root in ${params.fileName}, got <${root.name}>`);
  }

  const schema: AbiSchema = {
    fileName: params.fileName,
    schemaId: params.fileName.replace(/\.xml$/u, ""),
    path: params.schemaPath,
    types: [],
    interfaces: [],
    getMethods: [],
    messages: [],
  };

  for (const child of elementChildren(root)) {
    switch (child.name) {
      case "types":
        schema.types.push(...parseTypeDefinitions(child));
        break;
      case "interface":
        schema.interfaces.push(parseInterface(child));
        break;
      case "get_method":
        schema.getMethods.push(parseGetMethod(child));
        break;
      case "internal":
      case "ext_in":
      case "ext_out":
      case "jetton_payload":
      case "nft_payload":
        schema.messages.push(parseMessage(child));
        break;
      default:
        throw new Error(
          `Unsupported top-level tag <${child.name}> in ${params.fileName}`,
        );
    }
  }

  return schema;
}

function parseTypeDefinitions(node: XmlElementNode): AbiTypeDefinition[] {
  return splitStatements(readRawText(node)).map((tlb) => ({ tlb }));
}

function parseInterface(node: XmlElementNode): AbiInterface {
  const messageKinds = new Set(["internal", "ext_in", "ext_out"]);
  const result: AbiInterface = {
    name: requiredAttribute(node, "name"),
    attributes: node.attributes,
    codeHashes: [],
    getMethods: [],
    msgIn: [],
    msgOut: [],
    errors: [],
  };
  if (node.attributes.inherits !== undefined) {
    result.inherits = node.attributes.inherits;
  }

  for (const child of elementChildren(node)) {
    switch (child.name) {
      case "code_hash":
        result.codeHashes.push(normalizeInlineText(readRawText(child)));
        break;
      case "get_method":
        result.getMethods.push(parseMethodReference(child));
        break;
      case "msg_in":
        result.msgIn.push(...parseMessageReferences(child, messageKinds));
        break;
      case "msg_out":
        result.msgOut.push(...parseMessageReferences(child, messageKinds));
        break;
      case "error":
        result.errors.push(parseError(child));
        break;
      default:
        throw new Error(
          `Unsupported <${child.name}> inside <interface name="${result.name}">`,
        );
    }
  }

  return result;
}

function parseMethodReference(node: XmlElementNode): AbiMethodReference {
  const result: AbiMethodReference = {
    name: requiredAttribute(node, "name"),
    attributes: node.attributes,
  };
  if (node.attributes.version !== undefined) {
    result.version = node.attributes.version;
  }
  return result;
}

function parseMessageReferences(
  node: XmlElementNode,
  allowedKinds: Set<string>,
): AbiMessageReference[] {
  return elementChildren(node).map((child) => {
    if (!allowedKinds.has(child.name)) {
      throw new Error(`Unsupported message ref <${child.name}> inside <${node.name}>`);
    }

    return {
      kind: child.name as AbiMessageReference["kind"],
      name: requiredAttribute(child, "name"),
      attributes: child.attributes,
    };
  });
}

function parseError(node: XmlElementNode): AbiError {
  const result: AbiError = {
    text: normalizeInlineText(readRawText(node)),
    attributes: node.attributes,
  };
  if (node.attributes.code !== undefined) {
    result.code = node.attributes.code;
  }
  return result;
}

function parseGetMethod(node: XmlElementNode): AbiGetMethod {
  const result: AbiGetMethod = {
    name: requiredAttribute(node, "name"),
    fixedLength: parseBooleanAttribute(node.attributes.fixed_length),
    attributes: node.attributes,
  };
  if (node.attributes.version !== undefined) {
    result.version = node.attributes.version;
  }

  for (const child of elementChildren(node)) {
    switch (child.name) {
      case "input":
        result.input = parseFieldList(child);
        break;
      case "output":
        result.output = parseFieldList(child);
        break;
      default:
        throw new Error(
          `Unsupported <${child.name}> inside <get_method name="${result.name}">`,
        );
    }
  }

  return result;
}

function parseFieldList(node: XmlElementNode): AbiFieldList {
  const result: AbiFieldList = {
    fixedLength: parseBooleanAttribute(node.attributes.fixed_length),
    attributes: node.attributes,
    fields: elementChildren(node).map((child) => parseField(child)),
  };
  if (node.attributes.name !== undefined) {
    result.name = node.attributes.name;
  }
  if (node.attributes.version !== undefined) {
    result.version = node.attributes.version;
  }
  return result;
}

function parseField(node: XmlElementNode): AbiField {
  if (node.name === "tuple") {
    const result: AbiField = {
      kind: "tuple",
      tag: node.name,
      nullable: parseBooleanAttribute(node.attributes.nullable),
      list: parseBooleanAttribute(node.attributes.list),
      attributes: node.attributes,
      fields: elementChildren(node).map((child) => parseField(child)),
    };
    if (node.attributes.name !== undefined) {
      result.name = node.attributes.name;
    }
    return result;
  }

  const result: AbiField = {
    kind: "scalar",
    tag: node.name,
    nullable: parseBooleanAttribute(node.attributes.nullable),
    attributes: node.attributes,
    valueType: normalizeInlineText(readRawText(node)),
  };
  if (node.attributes.name !== undefined) {
    result.name = node.attributes.name;
  }
  return result;
}

function parseMessage(node: XmlElementNode): AbiMessage {
  if (!MESSAGE_TAGS.has(node.name as AbiMessageKind)) {
    throw new Error(`Unsupported message tag <${node.name}>`);
  }

  const rawTlb = trimBlockText(readRawText(node));
  return {
    kind: node.name as AbiMessageKind,
    name: requiredAttribute(node, "name"),
    fixedLength: parseBooleanAttribute(node.attributes.fixed_length),
    attributes: node.attributes,
    rawTlb,
    tlb: normalizeInlineText(rawTlb),
  };
}

function splitStatements(raw: string): string[] {
  const statements: string[] = [];
  let current = "";

  for (const char of raw) {
    current += char;
    if (char === ";") {
      const normalized = normalizeInlineText(current);
      if (normalized.length > 0) {
        statements.push(normalized);
      }
      current = "";
    }
  }

  const rest = normalizeInlineText(current);
  if (rest.length > 0) {
    statements.push(rest);
  }

  return statements;
}

function elementChildren(node: XmlElementNode): XmlElementNode[] {
  return node.children.filter((child): child is XmlElementNode => child.kind === "element");
}

function readRawText(node: XmlElementNode): string {
  return node.children
    .filter((child): child is Extract<XmlNode, { kind: "text" }> => child.kind === "text")
    .map((child) => child.value)
    .join("");
}

function normalizeInlineText(value: string): string {
  return value
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .join(" ")
    .replace(/\s+/gu, " ")
    .trim();
}

function trimBlockText(value: string): string {
  return value
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .join("\n")
    .trim();
}

function parseBooleanAttribute(value: string | undefined): boolean {
  return value === "true";
}

function requiredAttribute(node: XmlElementNode, name: string): string {
  const value = node.attributes[name];
  if (!value) {
    throw new Error(`Expected attribute "${name}" on <${node.name}>`);
  }
  return value;
}
