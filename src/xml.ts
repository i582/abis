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

/*
Decompiled FunC written to data/tonco/research/func/tonco_pool.fc
warning: decompile-func generated 37 warnings
  line 214: ;; unhandled UBITSIZE
  line 5513: ;; unhandled ISNAN
  line 5579: ;; unhandled UNPACKEDCONFIGTUPLE
  line 5612: ;; unhandled DICTIGET
  line 5613: ;; unhandled NULLSWAPIFNOT
  line 5618: ;; unhandled DICTIGET
  line 5619: ;; unhandled NULLSWAPIFNOT
  line 5719: ;; unhandled QMUL
  line 5721: ;; unhandled ISNAN
  line 5735: ;; unhandled QADD
  line 5736: ;; unhandled ISNAN
  line 5739: ;; unhandled UBITSIZE
  line 5742: ;; unhandled ISNAN
  line 5751: ;; unhandled UBITSIZE
  line 5759: ;; unhandled QMULDIV
  line 5760: ;; unhandled ISNAN
  line 5763: ;; unhandled UBITSIZE
  line 5766: ;; unhandled QMULDIVMOD
  line 5767: ;; unhandled ISNAN
  line 5776: ;; unhandled UBITSIZE
  line 6544: ;; unhandled DICTIGET
  line 6545: ;; unhandled NULLSWAPIFNOT
  line 6550: ;; unhandled DICTIGET
  line 6551: ;; unhandled NULLSWAPIFNOT
  line 6569: ;; unhandled DICTIDEL
  line 6581: ;; unhandled DICTIDEL
  line 6613: ;; unhandled GASCONSUMED
  line 6617: ;; unhandled DICTIGETPREVEQ
  line 6618: ;; unhandled NULLSWAPIFNOT2
  line 6620: ;; unhandled DICTIGETNEXT
  line 6621: ;; unhandled NULLSWAPIFNOT2
  line 6815: ;; unhandled LSHIFT#DIV 128
  line 6870: ;; unhandled UBITSIZE
  line 8018: ;; unhandled DICTIGETNEXT
  line 8019: ;; unhandled NULLSWAPIFNOT2
  line 8021: ;; unhandled DICTIGETPREV
  line 8022: ;; unhandled NULLSWAPIFNOT2
Error: decompile-func generated 37 warnings*/
