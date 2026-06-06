/// Hipo Finance Librarian interface for shared-library administration and surplus refunds.
contract HipoLibrarian {
    author: "Hipo Finance"
    version: "1.0"
    description: "Hipo Finance Librarian that stores the Treasury address, accepts library-management internal messages, and emits gas excess refunds."
    storage: HipoLibrarianStorage
    incomingMessages: HipoLibrarianIncomingMessage
    outgoingMessages: HipoLibrarianOutgoingMessage
}

/// Persistent Librarian state stored in the root data cell.
struct HipoLibrarianStorage {
    /// Hipo Treasury internal address authorized to add libraries, remove libraries, and withdraw surplus.
    treasury: address
}

/// Add a code cell to the TON library set; accepted only from the stored Treasury address.
struct (0x53d0473e) HipoLibrarianAddLibrary {
    /// Caller-selected query id parsed by the contract but not used in the SETLIBCODE action.
    queryId: uint64
    /// Referenced library code cell passed to TVM `SETLIBCODE` with public mode and ignore-errors flag.
    code: cell
}

/// Remove a code cell from the TON library set by hash; accepted only from the stored Treasury address.
struct (0x6bd0ce52) HipoLibrarianRemoveLibrary {
    /// Caller-selected query id parsed by the contract but not used in the CHANGELIB action.
    queryId: uint64
    /// SHA256 cell hash of the library code removed through TVM `CHANGELIB`.
    codeHash: uint256
}

/// Withdraw Librarian balance above the reserved storage fee; accepted only from the stored Treasury address.
struct (0x23355ffb) HipoLibrarianWithdrawSurplus {
    /// Caller-selected query id copied into the outgoing `gas_excess` body.
    queryId: uint64
    /// Internal destination that receives unreserved TON with the `gas_excess` body.
    returnExcess: address
}

/// Top up the Librarian TON balance; the verified source ignores payload after the opcode.
struct (0x5372158c) HipoLibrarianTopUp {
    /// Query id used by the Hipo wrapper/TL-B format; the FunC dispatcher does not consume it.
    queryId: uint64
}

/// Excess TON notification emitted after `withdraw_surplus`.
struct (0xd53276db) HipoLibrarianGasExcess {
    /// Query id copied from the incoming `withdraw_surplus` request.
    queryId: uint64
}

/// Internal message bodies accepted by the Hipo Librarian dispatcher.
type HipoLibrarianIncomingMessage =
    | HipoLibrarianAddLibrary
    | HipoLibrarianRemoveLibrary
    | HipoLibrarianWithdrawSurplus
    | HipoLibrarianTopUp

/// Internal message bodies emitted by the Hipo Librarian.
type HipoLibrarianOutgoingMessage =
    | HipoLibrarianGasExcess

/// Hipo Librarian exit-code catalog documented from shared source constants.
enum HipoLibrarianErrors {
    /// Sender is not the Treasury address stored in Librarian data.
    AccessDenied = 103
    /// Incoming internal message opcode is not supported by the Librarian dispatcher.
    InvalidOperation = 107
}
