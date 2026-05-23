import { XMLParser } from "fast-xml-parser";

export interface XmlTextNode {
  kind: "text";
  value: string;
}

export interface XmlElementNode {
  kind: "element";
  name: string;
  attributes: Record<string, string>;
  children: XmlNode[];
}

export type XmlNode = XmlTextNode | XmlElementNode;

const parser = new XMLParser({
  preserveOrder: true,
  ignoreAttributes: false,
  attributeNamePrefix: "",
  parseTagValue: false,
  parseAttributeValue: false,
  trimValues: false,
  commentPropName: "#comment",
  processEntities: false,
});

export function parseXmlDocument(xml: string): XmlElementNode {
  const parsed = parser.parse(xml);
  if (!Array.isArray(parsed)) {
    throw new Error("Expected preserveOrder XML AST to be an array");
  }

  const elements = parsed
    .map((entry) => convertEntry(entry))
    .filter((node): node is XmlElementNode => node?.kind === "element");

  if (elements.length !== 1) {
    throw new Error(`Expected a single XML root element, got ${elements.length}`);
  }

  const [root] = elements;
  if (!root) {
    throw new Error("Missing XML root element");
  }

  return root;
}

function convertEntry(entry: unknown): XmlNode | null {
  if (!isRecord(entry)) {
    return null;
  }

  if (typeof entry["#text"] === "string") {
    return {
      kind: "text",
      value: entry["#text"],
    };
  }

  if ("#comment" in entry) {
    return null;
  }

  const names = Object.keys(entry).filter((key) => key !== ":@");
  if (names.length !== 1) {
    throw new Error(`Expected exactly one XML node name, got ${names.join(", ")}`);
  }

  const [name] = names;
  if (!name) {
    throw new Error("Missing XML node name");
  }

  const rawChildren = entry[name];
  if (!Array.isArray(rawChildren)) {
    throw new Error(`Expected children array for XML element <${name}>`);
  }

  const rawAttributes = isRecord(entry[":@"]) ? entry[":@"] : {};
  const attributes: Record<string, string> = Object.fromEntries(
    Object.entries(rawAttributes)
      .filter(([, value]) => typeof value === "string")
      .map(([key, value]) => [key, value as string]),
  );

  const children = rawChildren
    .map((child) => convertEntry(child))
    .filter((child): child is XmlNode => child !== null);

  return {
    kind: "element",
    name,
    attributes,
    children,
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}
