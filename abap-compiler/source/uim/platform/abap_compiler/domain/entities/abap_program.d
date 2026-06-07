/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.entities.abap_program;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Represents a single ABAP program source artefact managed by the compiler service.
/// Corresponds to an ABAP "Programm" object stored in the Repository (SAP R/3 se38).
struct AbapProgram {
    mixin TenantEntity!AbapProgramId;

    ProgramType programType; /// Program type (report, class pool, …)
    string      title;       /// Short text description (up to 70 chars)
    string      language;    /// Original language key, e.g. "DE" / "EN"
    string      sourceCode;  /// Full ABAP source text
    long        createdAt;   /// Unix millis
    long        updatedAt;   /// Unix millis

    Json toJson() const {
        return entityToJson()
            .set("programType", to!string(programType))
            .set("title",       title)
            .set("language",    language)
            .set("sourceCode",  sourceCode);
    }

    static AbapProgram create(string id, TenantId tenantId, ProgramType pt, string title, string language, string src) {
        import core.time : MonoTime;
        AbapProgram p;
        p.initEntity(tenantId);

        p.id          = id;
        p.programType = pt;
        p.title       = title;
        p.language    = language;
        p.sourceCode  = src;

        return p;
    }
}
