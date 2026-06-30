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
ProgramType toProgramType(string value) {
    mixin(EnumSwitch("ProgramType", "unknown"));
}
ProgramType[] toProgramType(string[] values) {
    return values.map!(v => toProgramType(v)).array;
}
string toString(ProgramType type) {
    return type.to!string();
}
string[] toString(ProgramType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    assert(toProgramType("report") == ProgramType.report);
    assert(toProgramType("includeProgram") == ProgramType.includeProgram);
    assert(toProgramType("modulePool") == ProgramType.modulePool);
    assert(toProgramType("functionGroup") == ProgramType.functionGroup);
    assert(toProgramType("classPool") == ProgramType.classPool);         
    assert(toProgramType("interfacePool") == ProgramType.interfacePool);     
    assert(toProgramType("subroutinePool") == ProgramType.subroutinePool);    
    assert(toProgramType("typePool") == ProgramType.typePool);          
    assert(toProgramType("transformation") == ProgramType.transformation);    
    assert(toProgramType("unknown") == ProgramType.unknown);

    assert(toString(ProgramType.report) == "report");
    assert(toString(ProgramType.includeProgram) == "includeProgram");
    assert(toString(ProgramType.modulePool) == "modulePool");
    assert(toString(ProgramType.functionGroup) == "functionGroup");
    assert(toString(ProgramType.classPool) == "classPool");         
    assert(toString(ProgramType.interfacePool) == "interfacePool");     
    assert(toString(ProgramType.subroutinePool) == "subroutinePool");    
    assert(toString(ProgramType.typePool) == "typePool");          
    assert(toString(ProgramType.transformation) == "transformation");    
    assert(toString(ProgramType.unknown) == "unknown");

    assert(toProgramType(["report", "modulePool"]) == [ProgramType.report, ProgramType.modulePool]);
    assert(toString([ProgramType.functionGroup, ProgramType.classPool]) == ["functionGroup", "classPool"]);
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
    unknown
}
TokenType toTokenType(string value) {
    mixin(EnumSwitch("TokenType", "unknown"));
}
TokenType[] toTokenType(string[] values) {
    return values.map!(v => toTokenType(v)).array;
}
string toString(TokenType type) {
    return type.to!string();
}
string[] toString(TokenType[] types) {
    return types.map!(t => toString(t)).array;
}
///
unittest {
    assert(toTokenType("keyword") == TokenType.keyword);
    assert(toTokenType("identifier") == TokenType.identifier);
    assert(toTokenType("literal_integer") == TokenType.literal_integer);
    assert(toTokenType("literal_string") == TokenType.literal_string);
    assert(toTokenType("literal_char") == TokenType.literal_char);  
    assert(toTokenType("operator") == TokenType.operator);
    assert(toTokenType("comment") == TokenType.comment);
    assert(toTokenType("period") == TokenType.period);
    assert(toTokenType("comma") == TokenType.comma);
    assert(toTokenType("colon") == TokenType.colon);
    assert(toTokenType("lparen") == TokenType.lparen);
    assert(toTokenType("rparen") == TokenType.rparen);
    assert(toTokenType("whitespace") == TokenType.whitespace);
    assert(toTokenType("newline") == TokenType.newline);
    assert(toTokenType("eof") == TokenType.eof);
    assert(toTokenType("unknown") == TokenType.unknown);

    assert(toString(TokenType.keyword) == "keyword");
    assert(toString(TokenType.identifier) == "identifier");
    assert(toString(TokenType.literal_integer) == "literal_integer");
    assert(toString(TokenType.literal_string) == "literal_string");
    assert(toString(TokenType.literal_char) == "literal_char");  
    assert(toString(TokenType.operator) == "operator");
    assert(toString(TokenType.comment) == "comment");
    assert(toString(TokenType.period) == "period");
    assert(toString(TokenType.comma) == "comma");
    assert(toString(TokenType.colon) == "colon");
    assert(toString(TokenType.lparen) == "lparen");
    assert(toString(TokenType.rparen) == "rparen");
    assert(toString(TokenType.whitespace) == "whitespace");
    assert(toString(TokenType.newline) == "newline");
    assert(toString(TokenType.eof) == "eof");
    assert(toString(TokenType.unknown) == "unknown");

    assert(toTokenType(["keyword", "identifier"]) == [TokenType.keyword, TokenType.identifier]);
    assert(toString([TokenType.literal_string, TokenType.operator]) == ["literal_string", "operator"]);
}

// ---------------------------------------------------------------------------
// Visibility (ABAP OO section keywords)
// ---------------------------------------------------------------------------
enum OOVisibility {
    public_,
    protected_,
    private_
}
OOVisibility toOOVisibility(string value) {
    switch (value) {
        case "public": return OOVisibility.public_;
        case "protected": return OOVisibility.protected_;
        case "private": return OOVisibility.private_;
        default: return OOVisibility.public_; // default to public if unknown
    }
}
OOVisibility[] toOOVisibility(string[] values) {
    return values.map!(v => toOOVisibility(v)).array;
}
string toString(OOVisibility visibility) {
    switch (visibility) {
        case OOVisibility.public_: return "public";
        case OOVisibility.protected_: return "protected";
        case OOVisibility.private_: return "private";
        default: return "public"; // default to public if unknown
    }
}
string[] toString(OOVisibility[] visibilities) {
    return visibilities.map!(v => toString(v)).array;
}
///
unittest {
    assert(toOOVisibility("public") == OOVisibility.public_);
    assert(toOOVisibility("protected") == OOVisibility.protected_);
    assert(toOOVisibility("private") == OOVisibility.private_); 

    assert(toString(OOVisibility.public_) == "public");
    assert(toString(OOVisibility.protected_) == "protected");
    assert(toString(OOVisibility.private_) == "private");

    assert(toOOVisibility(["public", "private"]) == [OOVisibility.public_, OOVisibility.private_]);
    assert(toString([OOVisibility.protected_, OOVisibility.public_]) == ["protected", "public"]);
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
ProcessingMode toProcessingMode(string value) {
    mixin(EnumSwitch("ProcessingMode", "normal"));
}
ProcessingMode[] toProcessingMode(string[] values) {
    return values.map!(v => toProcessingMode(v)).array;
}
string toString(ProcessingMode mode) {
    return mode.to!string();
}
string[] toString(ProcessingMode[] modes) {
    return modes.map!(m => toString(m)).array;
}
///
unittest {
    assert(toProcessingMode("normal") == ProcessingMode.normal);
    assert(toProcessingMode("dialog") == ProcessingMode.dialog);
    assert(toProcessingMode("batch") == ProcessingMode.batch);
    assert(toProcessingMode("rfc") == ProcessingMode.rfc);      

assert(toString(ProcessingMode.normal) == "normal");
    assert(toString(ProcessingMode.dialog) == "dialog");
    assert(toString(ProcessingMode.batch) == "batch");
    assert(toString(ProcessingMode.rfc) == "rfc");      

    assert(toProcessingMode(["normal", "batch"]) == [ProcessingMode.normal, ProcessingMode.batch]);
    assert(toString([ProcessingMode.dialog, ProcessingMode.rfc]) == ["dialog", "rfc"]);
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
DiagnosticSeverity toDiagnosticSeverity(string value) {
    mixin(EnumSwitch("DiagnosticSeverity", "error"));
}
DiagnosticSeverity[] toDiagnosticSeverity(string[] values) {
    return values.map!(v => toDiagnosticSeverity(v)).array;
}
string toString(DiagnosticSeverity severity) {
    return severity.to!string();
}
string[] toString(DiagnosticSeverity[] severities) {
    return severities.map!(s => toString(s)).array;
}
///
unittest {
    assert(toDiagnosticSeverity("error") == DiagnosticSeverity.error);
    assert(toDiagnosticSeverity("warning") == DiagnosticSeverity.warning);
    assert(toDiagnosticSeverity("info") == DiagnosticSeverity.info);
    assert(toDiagnosticSeverity("hint") == DiagnosticSeverity.hint);

    assert(toString(DiagnosticSeverity.error) == "error");
    assert(toString(DiagnosticSeverity.warning) == "warning");
    assert(toString(DiagnosticSeverity.info) == "info");
    assert(toString(DiagnosticSeverity.hint) == "hint");    

    assert(toDiagnosticSeverity(["error", "info"]) == [DiagnosticSeverity.error, DiagnosticSeverity.info]);
    assert(toString([DiagnosticSeverity.warning, DiagnosticSeverity.hint]) == ["warning", "hint"]);
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
CompilationStatus toCompilationStatus(string value) {
    mixin(EnumSwitch("CompilationStatus", "pending"));
}
CompilationStatus[] toCompilationStatus(string[] values) {
    return values.map!(v => toCompilationStatus(v)).array;
}
string toString(CompilationStatus status) {
    return status.to!string();
}
string[] toString(CompilationStatus[] statuses) {
    return statuses.map!(s => toString(s)).array;
}
///
unittest {
    assert(toCompilationStatus("pending") == CompilationStatus.pending);
    assert(toCompilationStatus("running") == CompilationStatus.running);
    assert(toCompilationStatus("succeeded") == CompilationStatus.succeeded);
    assert(toCompilationStatus("failed") == CompilationStatus.failed);
    assert(toCompilationStatus("aborted") == CompilationStatus.aborted);    

    assert(toString(CompilationStatus.pending) == "pending");
    assert(toString(CompilationStatus.running) == "running");
    assert(toString(CompilationStatus.succeeded) == "succeeded");
    assert(toString(CompilationStatus.failed) == "failed");
    assert(toString(CompilationStatus.aborted) == "aborted");   

    assert(toCompilationStatus(["pending", "succeeded"]) == [CompilationStatus.pending, CompilationStatus.succeeded]);
    assert(toString([CompilationStatus.running, CompilationStatus.failed]) == ["running", "failed"]);
}
