/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.types;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

// ---------------------------------------------------------------------------
// Strong-typed IDs
// ---------------------------------------------------------------------------
alias ProgramId      = string;  /// ABAP program / report name (up to 40 chars, SAP convention)
alias ClassId        = string;  /// ABAP class name (up to 30 chars)
alias InterfaceId    = string;  /// ABAP interface name
alias FunctionGroupId= string;  /// Function-group (fugr) name
alias FunctionModuleId = string; /// Function-module name
alias DataTypeId     = string;  /// ABAP Dictionary data type name
alias CompilationJobId = string; /// Internal job UUID for a compilation run
alias TokenId        = size_t;  /// Ordinal position of a token in a source

// ---------------------------------------------------------------------------
// ABAP program category (corresponds to program attribute TYPE in ABAP)
// ---------------------------------------------------------------------------
enum ProgramType {
    report,            /// Executable program (TYPE 1)
    includeProgram,    /// Include (TYPE I)
    modulePool,        /// Module pool / dialog (TYPE M)
    functionGroup,     /// Function group (TYPE F)
    classPool,         /// Class pool (TYPE K)
    interfacePool,     /// Interface pool (TYPE J)
    subroutinePool,    /// Subroutine pool (TYPE S)
    typePool,          /// Type pool (TYPE T)
    transformation,    /// XSLT / ST transformation
    unknown
}

// ---------------------------------------------------------------------------
// Token types produced by the ABAP lexer
// ---------------------------------------------------------------------------
enum TokenType {
    keyword,
    identifier,
    literal_integer,
    literal_string,
    literal_char,
    operator,
    comment,
    period,             /// ABAP statement terminator '.'
    comma,
    colon,              /// chain colon ':'
    lparen,
    rparen,
    whitespace,
    newline,
    eof,
    unknown_
}

// ---------------------------------------------------------------------------
// Visibility (ABAP OO section keywords)
// ---------------------------------------------------------------------------
enum OOVisibility {
    public_,
    protected_,
    private_
}

// ---------------------------------------------------------------------------
// Processing mode
// ---------------------------------------------------------------------------
enum ProcessingMode {
    normal,        /// Standard report processing
    dialog,        /// Screen / dialog program
    batch,         /// Batch / background processing
    rfc            /// RFC-enabled function module
}

// ---------------------------------------------------------------------------
// Compilation severity
// ---------------------------------------------------------------------------
enum DiagnosticSeverity {
    error,
    warning,
    info,
    hint
}

// ---------------------------------------------------------------------------
// Compilation status
// ---------------------------------------------------------------------------
enum CompilationStatus {
    pending,
    running,
    succeeded,
    failed,
    aborted
}
