/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.entities.diagnostic;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// A compiler diagnostic (error, warning, info) emitted during lexing, parsing or
/// semantic analysis of an ABAP source unit.
struct Diagnostic {
    DiagnosticSeverity severity;  /// Error / warning / info / hint
    string             message;   /// Human-readable description
    size_t             line;      /// Source line (1-based, 0 = unknown)
    size_t             column;    /// Source column (1-based, 0 = unknown)
    string             code;      /// Short diagnostic code, e.g. "ABAP-E001"

    Json toJson() const {
        return Json.emptyObject
            .set("severity", to!string(severity))
            .set("message",  message)
            .set("line",     cast(long) line)
            .set("column",   cast(long) column)
            .set("code",     code);
    }
}
