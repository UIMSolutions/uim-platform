module uim.platform.abap_compiler.domain.enumerations;

import uim.platform.abap_compiler;

// mixin(ShowModule!());

@safe:
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
