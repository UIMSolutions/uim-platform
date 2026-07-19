/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.enumerations;

import uim.platform.abap_compiler;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// ABAP program category (corresponds to program attribute TYPE in ABAP)
// ---------------------------------------------------------------------------
enum ProgramType {
    report, /// Executable program (TYPE 1)
    includeProgram, /// Include (TYPE I)
    modulePool, /// Module pool / dialog (TYPE M)
    functionGroup, /// Function group (TYPE F)
    classPool, /// Class pool (TYPE K)
    interfacePool, /// Interface pool (TYPE J)
    subroutinePool, /// Subroutine pool (TYPE S)
    typePool, /// Type pool (TYPE T)
    transformation, /// XSLT / ST transformation
    unknown
}

ProgramType toProgramType(string value) {
    mixin(EnumSwitch("ProgramType", "unknown"));
}

ProgramType[] toProgramTypes(string[] values) {
    return values.map!toProgramType.array;
}

string toString(ProgramType type) {
    return type.to!string();
}

string[] toStrings(ProgramType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("report".toProgramType == ProgramType.report);
    assert("includeProgram".toProgramType == ProgramType.includeProgram);
    assert("modulePool".toProgramType == ProgramType.modulePool);
    assert("functionGroup".toProgramType == ProgramType.functionGroup);
    assert("classPool".toProgramType == ProgramType.classPool);
    assert("interfacePool".toProgramType == ProgramType.interfacePool);
    assert("subroutinePool".toProgramType == ProgramType.subroutinePool);
    assert("typePool".toProgramType == ProgramType.typePool);
    assert("transformation".toProgramType == ProgramType.transformation);
    assert("unknown".toProgramType == ProgramType.unknown);

    assert(ProgramType.report.toString == "report");
    assert(ProgramType.includeProgram.toString == "includeProgram");
    assert(ProgramType.modulePool.toString == "modulePool");
    assert(ProgramType.functionGroup.toString == "functionGroup");
    assert(ProgramType.classPool.toString == "classPool");
    assert(ProgramType.interfacePool.toString == "interfacePool");
    assert(ProgramType.subroutinePool.toString == "subroutinePool");
    assert(ProgramType.typePool.toString == "typePool");
    assert(ProgramType.transformation.toString == "transformation");
    assert(ProgramType.unknown.toString == "unknown");

    assert(["report", "modulePool"].toProgramTypes == [
            ProgramType.report, ProgramType.modulePool
        ]);
    assert([ProgramType.functionGroup, ProgramType.classPool].toStrings == [
            "functionGroup", "classPool"
        ]);
}

// ---------------------------------------------------------------------------
// Token types produced by the ABAP lexer
// ---------------------------------------------------------------------------
enum TokenType {
    unknown,
    keyword,
    identifier,
    literal_integer,
    literal_string,
    literal_char,
    operator,
    comment,
    period, /// ABAP statement terminator '.'
    comma,
    colon, /// chain colon ':'
    lparen,
    rparen,
    whitespace,
    newline,
    eof
}

TokenType toTokenType(string value) {
    mixin(EnumSwitch("TokenType", "unknown"));
}

TokenType[] toTokenTypes(string[] values) {
    return values.map!toTokenType.array;
}

string toString(TokenType type) {
    return type.to!string();
}

string[] toStrings(TokenType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("keyword".toTokenType == TokenType.keyword);
    assert("identifier".toTokenType == TokenType.identifier);
    assert("literal_integer".toTokenType == TokenType.literal_integer);
    assert("literal_string".toTokenType == TokenType.literal_string);
    assert("literal_char".toTokenType == TokenType.literal_char);
    assert("operator".toTokenType == TokenType.operator);
    assert("comment".toTokenType == TokenType.comment);
    assert("period".toTokenType == TokenType.period);
    assert("comma".toTokenType == TokenType.comma);
    assert("colon".toTokenType == TokenType.colon);
    assert("lparen".toTokenType == TokenType.lparen);
    assert("rparen".toTokenType == TokenType.rparen);
    assert("whitespace".toTokenType == TokenType.whitespace);
    assert("newline".toTokenType == TokenType.newline);
    assert("eof".toTokenType == TokenType.eof);
    assert("unknown".toTokenType == TokenType.unknown);

    assert("".toTokenType == TokenType.unknown);
    assert("something".toTokenType == TokenType.unknown);

    assert(TokenType.keyword.toString == "keyword");
    assert(TokenType.identifier.toString == "identifier");
    assert(TokenType.literal_integer.toString == "literal_integer");
    assert(TokenType.literal_string.toString == "literal_string");
    assert(TokenType.literal_char.toString == "literal_char");
    assert(TokenType.operator.toString == "operator");
    assert(TokenType.comment.toString == "comment");
    assert(TokenType.period.toString == "period");
    assert(TokenType.comma.toString == "comma");
    assert(TokenType.colon.toString == "colon");
    assert(TokenType.lparen.toString == "lparen");
    assert(TokenType.rparen.toString == "rparen");
    assert(TokenType.whitespace.toString == "whitespace");
    assert(TokenType.newline.toString == "newline");
    assert(TokenType.eof.toString == "eof");
    assert(TokenType.unknown.toString == "unknown");

    assert(["keyword", "identifier"].toTokenTypes == [
            TokenType.keyword, TokenType.identifier
        ]);
    assert([TokenType.literal_string, TokenType.operator].toStrings == [
            "literal_string", "operator"
        ]);
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
    case "public":
        return OOVisibility.public_;
    case "protected":
        return OOVisibility.protected_;
    case "private":
        return OOVisibility.private_;
    default:
        return OOVisibility.public_; // default to public if unknown
    }
}

OOVisibility[] toOOVisibilities(string[] values) {
    return values.map!(v => toOOVisibility(v)).array;
}

string toString(OOVisibility visibility) {
    switch (visibility) {
    case OOVisibility.public_:
        return "public";
    case OOVisibility.protected_:
        return "protected";
    case OOVisibility.private_:
        return "private";
    default:
        return "public"; // default to public if unknown
    }
}

string[] toStrings(OOVisibility[] visibilities) {
    return visibilities.map!(v => toString(v)).array;
}
///
unittest {
    assert("public".toOOVisibility == OOVisibility.public_);
    assert("protected".toOOVisibility == OOVisibility.protected_);
    assert("private".toOOVisibility == OOVisibility.private_);

    assert(OOVisibility.public_.toString == "public");
    assert(OOVisibility.protected_.toString == "protected");
    assert(OOVisibility.private_.toString == "private");

    assert(["public", "private"].toOOVisibilities == [
            OOVisibility.public_, OOVisibility.private_
        ]);
    assert([OOVisibility.protected_, OOVisibility.public_].toStrings == [
            "protected", "public"
        ]);
}

// ---------------------------------------------------------------------------
// Processing mode
// ---------------------------------------------------------------------------
enum ProcessingMode {
    normal, /// Standard report processing
    dialog, /// Screen / dialog program
    batch, /// Batch / background processing
    rfc /// RFC-enabled function module
}

ProcessingMode toProcessingMode(string value) {
    mixin(EnumSwitch("ProcessingMode", "normal"));
}

ProcessingMode[] toProcessingModes(string[] values) {
    return values.map!toProcessingMode.array;
}

string toString(ProcessingMode mode) {
    return mode.to!string();
}

string[] toStrings(ProcessingMode[] modes) {
    return modes.map!toString.array;
}
///
unittest {
    assert("normal".toProcessingMode == ProcessingMode.normal);
    assert("dialog".toProcessingMode == ProcessingMode.dialog);
    assert("batch".toProcessingMode == ProcessingMode.batch);
    assert("rfc".toProcessingMode == ProcessingMode.rfc);

    assert("".toProcessingMode == ProcessingMode.normal);
    assert("unknown".toProcessingMode == ProcessingMode.normal);

    assert(toString(ProcessingMode.normal) == "normal");
    assert(toString(ProcessingMode.dialog) == "dialog");
    assert(toString(ProcessingMode.batch) == "batch");
    assert(toString(ProcessingMode.rfc) == "rfc");

    assert(["normal", "batch"].toProcessingModes == [
            ProcessingMode.normal, ProcessingMode.batch
        ]);
    assert([ProcessingMode.dialog, ProcessingMode.rfc].toStrings == [
            "dialog", "rfc"
        ]);
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

DiagnosticSeverity[] toDiagnosticSeverities(string[] values) {
    return values.map!(v => toDiagnosticSeverity(v)).array;
}

string toString(DiagnosticSeverity severity) {
    return severity.to!string();
}

string[] toStrings(DiagnosticSeverity[] severities) {
    return severities.map!toString.array;
}
///
unittest {
    assert("error".toDiagnosticSeverity == DiagnosticSeverity.error);
    assert("warning".toDiagnosticSeverity == DiagnosticSeverity.warning);
    assert("info".toDiagnosticSeverity == DiagnosticSeverity.info);
    assert("hint".toDiagnosticSeverity == DiagnosticSeverity.hint);
    
    assert("".toDiagnosticSeverity == DiagnosticSeverity.error);
    assert("unknown".toDiagnosticSeverity == DiagnosticSeverity.error);

    assert(toString(DiagnosticSeverity.error) == "error");
    assert(toString(DiagnosticSeverity.warning) == "warning");
    assert(toString(DiagnosticSeverity.info) == "info");
    assert(toString(DiagnosticSeverity.hint) == "hint");

    assert(["error", "info"].toDiagnosticSeverities == [
            DiagnosticSeverity.error, DiagnosticSeverity.info
        ]);
    assert([DiagnosticSeverity.warning, DiagnosticSeverity.hint].toStrings == [
            "warning", "hint"
        ]);
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

CompilationStatus[] toCompilationStatuses(string[] values) {
    return values.map!toCompilationStatus.array;
}

string toString(CompilationStatus status) {
    return status.to!string();
}

string[] toStrings(CompilationStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("pending".toCompilationStatus == CompilationStatus.pending);
    assert("running".toCompilationStatus == CompilationStatus.running);
    assert("succeeded".toCompilationStatus == CompilationStatus.succeeded);
    assert("failed".toCompilationStatus == CompilationStatus.failed);

    assert("".toCompilationStatus == CompilationStatus.pending);
    assert("unknown".toCompilationStatus == CompilationStatus.pending);

    assert(CompilationStatus.pending.toString == "pending");
    assert(CompilationStatus.running.toString == "running");
    assert(CompilationStatus.succeeded.toString == "succeeded");
    assert(CompilationStatus.failed.toString == "failed");
    assert(CompilationStatus.aborted.toString == "aborted");

    assert(["pending", "succeeded"].toCompilationStatuses == [
            CompilationStatus.pending, CompilationStatus.succeeded
        ]);
    assert([CompilationStatus.running, CompilationStatus.failed].toStrings == [
            "running", "failed"
        ]);
}
