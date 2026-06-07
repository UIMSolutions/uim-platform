/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.services.code_generator;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Transforms a semantically-valid ParsedStatement list into a simplified
/// Intermediate Representation (IR) — a human-readable line-oriented format
/// that could serve as input to a bytecode emitter or interpreter.
///
/// IR format (one line per statement):
///   STMT_TYPE [arg1] [arg2] …
struct CodeGenerator {
    string[] generate(ParsedStatement[] stmts) @safe {
        string[] ir;
        foreach (stmt; stmts) {
            if (stmt.tokens.length == 0) continue;
            ir ~= stmt.tokens.join(" ");
        }
        return ir;
    }
}
