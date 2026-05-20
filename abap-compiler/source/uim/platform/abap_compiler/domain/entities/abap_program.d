/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.entities.abap_program;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Represents a single ABAP program source artefact managed by the compiler service.
/// Corresponds to an ABAP "Programm" object stored in the Repository (SAP R/3 se38).
struct AbapProgram {
    ProgramId   id;          /// Unique program / report name (matches SAP object key)
    string      tenantId;    /// Multi-tenant discriminator
    ProgramType programType; /// Program type (report, class pool, …)
    string      title;       /// Short text description (up to 70 chars)
    string      language;    /// Original language key, e.g. "DE" / "EN"
    string      sourceCode;  /// Full ABAP source text
    long        createdAt;   /// Unix millis
    long        updatedAt;   /// Unix millis

    bool isNull() const { return id.length == 0; }

    Json toJson() const {
        return Json.emptyObject
            .set("id",          id)
            .set("tenantId",    tenantId)
            .set("programType", to!string(programType))
            .set("title",       title)
            .set("language",    language)
            .set("sourceCode",  sourceCode)
            .set("createdAt",   createdAt)
            .set("updatedAt",   updatedAt);
    }

    static AbapProgram create(string id, string tenantId, ProgramType pt, string title, string language, string src) {
        import core.time : MonoTime;
        AbapProgram p;
        p.id          = id;
        p.tenantId    = tenantId;
        p.programType = pt;
        p.title       = title;
        p.language    = language;
        p.sourceCode  = src;
        p.createdAt   = MonoTime.currTime.ticks;
        p.updatedAt   = p.createdAt;
        return p;
    }
}
