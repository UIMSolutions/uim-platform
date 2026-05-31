/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.entities.compilation_job;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Tracks a single compilation request: input program -> status -> result.
struct CompilationJob {
    mixin TenantEntity!CompilationJobId;          /// UUID
    AbapProgramId        programId;   /// Source program to compile
    CompilationStatus status;     /// Current lifecycle state
    Diagnostic[]     diagnostics; /// All diagnostics from this run
    string[]         generatedCode;/// Simplified IR / intermediate code lines
    long             startedAt;
    long             finishedAt;

    bool hasErrors() const {
        foreach (d; diagnostics)
            if (d.severity == DiagnosticSeverity.error) return true;
        return false;
    }

    Json toJson() const {
        auto jDiag = diagnostics.map!(d => d.toJson()).array.toJson;
        auto jCode = generatedCode.map!(c => Json(c)).array.toJson;

        return entityToJson()
            .set("programId",     programId)
            .set("status",        to!string(status))
            .set("diagnostics",   jDiag)
            .set("generatedCode", jCode)
            .set("startedAt",     startedAt)
            .set("finishedAt",    finishedAt);
    }

    static CompilationJob create(TenantId tenantId, AbapProgramId pid) {
        import core.time : MonoTime;
        import std.uuid  : randomUUID;
        CompilationJob j;
        j.initEntity(tenantId);
        j.id         = randomUUID().toString();
        j.programId  = pid;
        j.status     = CompilationStatus.pending;
        j.startedAt  = MonoTime.currTime.ticks;
        j.finishedAt = 0;
        return j;
    }
}
