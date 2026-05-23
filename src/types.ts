/**
 * This file defines the in-memory model we use after loading XML ABI schemas.
 *
 * Important boundary:
 * - this is not a full TL-B AST;
 * - this is not a full TON type system model;
 * - this is a normalized representation of the XML files from `schemas/`.
 *
 * The goal of this model is practical downstream work:
 * - load all schemas consistently;
 * - preserve field order from ABI declarations;
 * - keep enough source detail for inspection and code generation;
 * - expose common TON ABI concepts in a typed form.
 *
 * In other words, these interfaces answer:
 * "what ABI declarations exist in the repository and how are they shaped?"
 * They do not try to fully parse every TL-B construct into semantic subnodes.
 */

/**
 * Kind of ABI message declaration found in XML.
 *
 * In TON terms, this tells you where the payload is expected to appear:
 * - `internal`: body of an internal message between contracts
 * - `ext_in`: body of an external inbound message sent from outside the chain
 * - `ext_out`: body of an external outbound message emitted by a contract
 * - `jetton_payload`: payload embedded into jetton transfer flows
 * - `nft_payload`: payload embedded into NFT transfer flows
 *
 * These values come from top-level XML tags such as `<internal>` or `<ext_out>`.
 */
export type AbiMessageKind =
  | "internal"
  | "ext_in"
  | "ext_out"
  | "jetton_payload"
  | "nft_payload";

export interface AbiRegistry {
  /**
   * All schemas loaded from the `schemas` directory.
   *
   * The order is the loader order, currently sorted by file name.
   */
  schemas: AbiSchema[];
}

export interface AbiSchema {
  /** Source XML file name, for example `wallets.xml`. */
  fileName: string;
  /**
   * Stable schema identifier derived from file name, for example `wallets`.
   *
   * This is the most convenient key for indexing schemas in memory.
   */
  schemaId: string;
  /** Absolute path to the source XML file on disk. */
  path: string;
  /**
   * TL-B type declarations collected from the `<types>` block.
   *
   * These are reusable type aliases / constructors referenced later by
   * get-method shapes or message bodies. We currently keep them as normalized
   * TL-B text rather than fully parsing TL-B grammar.
   */
  types: AbiTypeDefinition[];
  /**
   * Contract interfaces declared in the schema.
   *
   * An interface groups capabilities of a contract family:
   * code hashes, supported get-methods, accepted inbound messages, emitted
   * outbound messages, and declared error codes.
   */
  interfaces: AbiInterface[];
  /**
   * Top-level get-method declarations with typed IO shape.
   *
   * These are reusable ABI method definitions. Interfaces typically reference
   * them by name and may select a specific `version` variant.
   */
  getMethods: AbiGetMethod[];
  /**
   * Top-level message and payload declarations.
   *
   * This includes internal/external message bodies and payloads reused by
   * higher-level protocols such as jettons or NFTs.
   */
  messages: AbiMessage[];
}

export interface AbiTypeDefinition {
  /**
   * Raw normalized TL-B declaration text, including trailing `;` when present.
   *
   * Example:
   * `transfer#0f8a7ea5 query_id:uint64 amount:(VarUInteger 16) = InternalMsgBody;`
   *
   * We keep it as text because downstream tasks may want to print it, diff it,
   * or parse it later with a dedicated TL-B parser.
   */
  tlb: string;
}

export interface AbiInterface {
  /**
   * Interface name, for example `jetton_wallet` or `wallet_v4r2`.
   *
   * This is the logical capability name from XML, not a code hash.
   */
  name: string;
  /**
   * Optional parent interface declared via `inherits`.
   *
   * This is inheritance at the schema-description level. It means "this
   * interface should be understood as extending another known interface".
   */
  inherits?: string;
  /**
   * Raw XML attributes preserved as-is.
   *
   * We keep them to avoid losing source detail that may matter later, even if
   * there is not yet a dedicated typed field for every attribute.
   */
  attributes: Record<string, string>;
  /**
   * Known code hashes associated with this interface implementation.
   *
   * In practice this is one of the strongest identifiers of a deployed TON
   * contract implementation.
   */
  codeHashes: string[];
  /**
   * Get-method references exposed by this interface.
   *
   * These are references by name, not inline copies of method definitions.
   */
  getMethods: AbiMethodReference[];
  /**
   * Messages this interface accepts as inbound traffic.
   *
   * This tells you which declared message bodies may legally arrive at the
   * contract according to the schema.
   */
  msgIn: AbiMessageReference[];
  /**
   * Messages this interface emits as outbound traffic.
   *
   * This is useful for tracing cross-contract protocol behavior.
   */
  msgOut: AbiMessageReference[];
  /**
   * Declared error codes and their human-readable text.
   *
   * These usually document TVM exit codes or contract-specific failures.
   */
  errors: AbiError[];
}

export interface AbiMethodReference {
  /**
   * Referenced get-method name.
   *
   * Resolve this against `AbiSchema.getMethods`.
   */
  name: string;
  /**
   * Optional ABI variant/version selector, for example `stonfi_v2`.
   *
   * Some schemas reuse a single method name with different result shapes.
   * `version` is the disambiguator chosen by the schema author.
   */
  version?: string;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
}

export interface AbiMessageReference {
  /**
   * Message direction/type used by the interface reference.
   *
   * This is narrower than `AbiMessageKind`: interface references only point to
   * `internal`, `ext_in`, or `ext_out` declarations.
   */
  kind: Extract<AbiMessageKind, "internal" | "ext_in" | "ext_out">;
  /**
   * Referenced message name.
   *
   * Resolve this against `AbiSchema.messages`.
   */
  name: string;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
}

export interface AbiError {
  /**
   * Numeric or string error code if present in XML.
   *
   * The XML uses string attributes, so we preserve the original form rather
   * than coercing it to a number.
   */
  code?: string;
  /** Human-readable error description from the XML body. */
  text: string;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
}

export interface AbiGetMethod {
  /**
   * Get-method name exactly as declared in XML.
   *
   * In TON, a get-method is a read-only method callable off-chain.
   */
  name: string;
  /**
   * Optional variant/version selector for overloaded ABI shapes.
   *
   * The same method name may have several schema variants depending on
   * contract family or protocol generation.
   */
  version?: string;
  /**
   * Whether the method node itself is marked `fixed_length="true"` in XML.
   *
   * This flag is schema metadata. It usually indicates that the input/output
   * tuple shape is expected to have a stable, exact arity.
   */
  fixedLength: boolean;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
  /**
   * Ordered input fields accepted by the get-method.
   *
   * Order matters because TON stack arguments are positional.
   */
  input?: AbiFieldList;
  /**
   * Ordered output fields returned by the get-method.
   *
   * Order matters because TON stack results are positional.
   */
  output?: AbiFieldList;
}

export interface AbiFieldList {
  /**
   * Optional logical name of this input/output shape.
   *
   * Some schemas label an output variant, for example `name="jetton"`.
   */
  name?: string;
  /**
   * Optional variant/version selector on the field list itself.
   *
   * This is commonly used when one get-method has several ABI shapes under the
   * same name.
   */
  version?: string;
  /**
   * Whether this list is marked as fixed-length in XML.
   *
   * Treat this as ABI metadata, not as a proof that the runtime data is always
   * valid.
   */
  fixedLength: boolean;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
  /**
   * Ordered field definitions exactly in ABI order.
   *
   * This is the most important property for decoding, encoding, codegen, and
   * documentation.
   */
  fields: AbiField[];
}

interface AbiFieldBase {
  /**
   * Original XML tag name, for example `int`, `slice`, `cell`, or `tuple`.
   *
   * This is the transport/container category from the XML DSL, not the full
   * business meaning of the field.
   */
  tag: string;
  /**
   * Field name if one was declared in XML.
   *
   * This is what humans will usually use when talking about the ABI field.
   */
  name?: string;
  /**
   * Whether the field is explicitly marked nullable in XML.
   *
   * This means the schema allows absence/null-like encoding for the field.
   * The exact binary representation depends on the ABI/TL-B convention behind
   * the field type.
   */
  nullable: boolean;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
}

export interface AbiScalarField extends AbiFieldBase {
  /**
   * Scalar field backed by a single XML node such as `<int>` or `<slice>`.
   *
   * "Scalar" here means "not a nested tuple in the XML model". It does not
   * necessarily mean "primitive" in the TON sense, because the value type may
   * still reference a complex logical type such as `DNS_RecordSet`.
   */
  kind: "scalar";
  /**
   * Declared TON/ABI type text stored inside the XML node body.
   *
   * Examples:
   * - `uint64`
   * - `bool`
   * - `msgaddress`
   * - `cell`
   * - `DedustAsset`
   *
   * This value is intentionally preserved as source text. We do not currently
   * split it into a richer semantic type model.
   */
  valueType: string;
}

export interface AbiTupleField extends AbiFieldBase {
  /**
   * Structured field containing nested ordered fields.
   *
   * In practice this models tuple-like stack values or repeated structured
   * records returned by get-methods.
   */
  kind: "tuple";
  /**
   * Whether the tuple represents a repeated list of tuples.
   *
   * Example: `<tuple name="nominators" list="true">...</tuple>`
   * means "a list where each item has the nested tuple shape".
   */
  list: boolean;
  /** Nested fields inside the tuple, preserved in declaration order. */
  fields: AbiField[];
}

/**
 * Any field inside get-method input/output: scalar value or nested tuple.
 *
 * This is the recursive core of the get-method shape model.
 */
export type AbiField = AbiScalarField | AbiTupleField;

export interface AbiMessage {
  /**
   * Message declaration kind, for example `internal` or `ext_out`.
   *
   * This tells you in which TON messaging context the payload is expected.
   */
  kind: AbiMessageKind;
  /**
   * Message name from the XML `name` attribute.
   *
   * This is the symbolic identifier used by interfaces to reference the
   * message declaration.
   */
  name: string;
  /**
   * Whether the message is marked `fixed_length="true"` in XML.
   *
   * As with methods, this is schema metadata rather than a full semantic proof
   * about the binary layout.
   */
  fixedLength: boolean;
  /** Raw XML attributes preserved as-is. */
  attributes: Record<string, string>;
  /**
   * Message TL-B body with line breaks preserved in a readable normalized block form.
   *
   * Use this when you want to display or inspect the declaration in a way that
   * still resembles the source XML formatting.
   */
  rawTlb: string;
  /**
   * Fully normalized single-line TL-B declaration text.
   *
   * Use this when you want a stable string for logging, comparison, search, or
   * downstream parsing.
   */
  tlb: string;
}
