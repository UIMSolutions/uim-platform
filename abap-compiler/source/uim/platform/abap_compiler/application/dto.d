/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.application.dto;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

// ---------------------------------------------------------------------------
// Program management DTOs
// ---------------------------------------------------------------------------

struct CreateProgramRequest {
    TenantId    tenantId;
    AbapProgramId   programId;
    ProgramType programType;
    string      title;
    string      language;
    string      sourceCode;
}

struct UpdateProgramRequest {
    TenantId    tenantId;
    AbapProgramId programId;
    string    title;
    string    language;
    string    sourceCode;
}

// ---------------------------------------------------------------------------
// Compilation DTOs
// ---------------------------------------------------------------------------

struct CompileRequest {
    TenantId    tenantId;
    AbapProgramId programId;
    string    sourceCode; /// Optional override — if empty, source is loaded from repo
}

struct CompileResponse {
    CompilationJobId jobId;
    CompilationStatus status;
    Diagnostic[]      diagnostics;
    string[]          generatedCode;
    bool              success;
    string            error;

    Json toJson() const {
        auto jDiag = Json.emptyArray;
        foreach (d; diagnostics) jDiag ~= d.toJson();

        auto jCode = Json.emptyArray;
        foreach (c; generatedCode) jCode ~= Json(c);

        return Json.emptyObject
            .set("jobId",         jobId)
            .set("status",        to!string(status))
            .set("diagnostics",   jDiag)
            .set("generatedCode", jCode)
            .set("success",       success)
            .set("error",         error);
    }
}

