/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.services.semantic_analyser;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// Performs static semantic checks on the parsed ABAP statement list.
/// Checks described in the ABAP keyword documentation (7.51):
///   - Unknown / misspelled top-level statements
///   - Missing END* counterparts for block openers
///   - Deprecated statements (FORM/PERFORM discouraged in OO programs)
struct SemanticAnalyser {
    private static /* immutable */ string[] BLOCK_OPENERS = [
        "IF", "LOOP", "WHILE", "DO", "TRY",
        "CLASS", "METHOD", "FORM", "FUNCTION", "SELECT",
        "CASE"
    ];
    private static /* immutable */ string[string] BLOCK_CLOSERS;

    shared static this() @trusted {
        (cast() BLOCK_CLOSERS)["IF"]       = "ENDIF";
        (cast() BLOCK_CLOSERS)["LOOP"]     = "ENDLOOP";
        (cast() BLOCK_CLOSERS)["WHILE"]    = "ENDWHILE";
        (cast() BLOCK_CLOSERS)["DO"]       = "ENDDO";
        (cast() BLOCK_CLOSERS)["TRY"]      = "ENDTRY";
        (cast() BLOCK_CLOSERS)["CLASS"]    = "ENDCLASS";
        (cast() BLOCK_CLOSERS)["METHOD"]   = "ENDMETHOD";
        (cast() BLOCK_CLOSERS)["FORM"]     = "ENDFORM";
        (cast() BLOCK_CLOSERS)["FUNCTION"] = "ENDFUNCTION";
        (cast() BLOCK_CLOSERS)["SELECT"]   = "ENDSELECT";
        (cast() BLOCK_CLOSERS)["CASE"]     = "ENDCASE";
    }

    Diagnostic[] analyse(ParsedStatement[] stmts) @safe {
        Diagnostic[] diagnostics;
        string[]     openBlocks;

        foreach (stmt; stmts) {
            immutable upper = stmt.statementType;

            // Check block openers
            foreach (opener; BLOCK_OPENERS) {
                if (upper == opener) {
                    openBlocks ~= opener;
                    break;
                }
            }

            // Check block closers
            foreach (opener, closer; BLOCK_CLOSERS) {
                if (upper == closer) {
                    if (openBlocks.length == 0 || openBlocks[$ - 1] != opener) {
                        diagnostics ~= Diagnostic(
                            DiagnosticSeverity.error,
                            "Unexpected '" ~ upper ~ "' without matching '" ~ opener ~ "'",
                            stmt.startLine, 0,
                            "ABAP-S001"
                        );
                    } else {
                        openBlocks = openBlocks[0 .. $ - 1];
                    }
                    break;
                }
            }

            // Deprecation hint: PERFORM inside CLASS … ENDCLASS
            if (upper == "PERFORM") {
                diagnostics ~= Diagnostic(
                    DiagnosticSeverity.warning,
                    "PERFORM (subroutine call) is deprecated in ABAP Objects — use METHOD instead",
                    stmt.startLine, 0,
                    "ABAP-W001"
                );
            }
        }

        // Unclosed blocks
        foreach (remaining; openBlocks) {
            auto closer = BLOCK_CLOSERS.get(remaining, "END" ~ remaining);
            diagnostics ~= Diagnostic(
                DiagnosticSeverity.error,
                "Unclosed block '" ~ remaining ~ "': missing '" ~ closer ~ "'",
                0, 0,
                "ABAP-S002"
            );
        }

        return diagnostics;
    }
}
