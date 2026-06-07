/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.services.parser;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// A lightweight recursive-descent parser for ABAP statements.
/// Produces a flat list of ParsedStatement structures (a simplified AST).
/// Covers the ABAP programming models described in the ABAP overview:
///   - Report / executable programs
///   - ABAP Objects (CLASS … IMPLEMENTATION, METHOD, INTERFACE)
///   - Data declarations (DATA, TYPES, FIELD-SYMBOLS)
///   - Flow control (IF/ENDIF, LOOP/ENDLOOP, WHILE/ENDWHILE, DO/ENDDO, TRY/ENDTRY)
///   - Database access (SELECT … INTO … FROM … WHERE … ENDSELECT)
///   - Modularisation (FORM/ENDFORM, FUNCTION/ENDFUNCTION)
struct ParsedStatement {
    string   statementType; /// e.g. "DATA", "IF", "SELECT", "CLASS", …
    string[] tokens;        /// token values of this statement (until next '.')
    size_t   startLine;
    size_t   endLine;

    Json toJson() const {
        auto jarr = Json.emptyArray;
        foreach (t; tokens) jarr ~= Json(t);
        return Json.emptyObject
            .set("statementType", statementType)
            .set("tokens",        jarr)
            .set("startLine",     cast(long) startLine)
            .set("endLine",       cast(long) endLine);
    }
}

struct ParseResult {
    ParsedStatement[] statements;
    Diagnostic[]      diagnostics;

    bool hasErrors() const {
        foreach (d; diagnostics)
            if (d.severity == DiagnosticSeverity.error) return true;
        return false;
    }
}

/// Stateless ABAP parser — call parse() per source unit.
struct AbapParser {
    ParseResult parse(Token[] tokens) @safe {
        ParseResult result;
        size_t      pos = 0;

        Token current() @safe {
            return pos < tokens.length ? tokens[pos] : tokens[$ - 1];
        }

        void advance() @safe { if (pos < tokens.length) pos++; }

        // Skip whitespace, newlines and comments
        void skipNonCode() @safe {
            while (pos < tokens.length &&
                   (current.type == TokenType.whitespace ||
                    current.type == TokenType.newline     ||
                    current.type == TokenType.comment))
                advance();
        }

        // Collect all tokens belonging to one ABAP statement (up to and including '.')
        ParsedStatement collectStatement() @safe {
            skipNonCode();
            if (pos >= tokens.length || current.type == TokenType.eof)
                return ParsedStatement.init;

            ParsedStatement stmt;
            stmt.startLine = current.line;
            string[] toks;

            while (pos < tokens.length &&
                   current.type != TokenType.period &&
                   current.type != TokenType.eof) {
                if (current.type != TokenType.whitespace &&
                    current.type != TokenType.newline     &&
                    current.type != TokenType.comment)
                    toks ~= current.value;
                stmt.endLine = current.line;
                advance();
            }

            if (current.type == TokenType.period) { stmt.endLine = current.line; advance(); }

            stmt.tokens        = toks;
            stmt.statementType = toks.length > 0 ? toks[0].toUpper : "";
            return stmt;
        }

        while (pos < tokens.length && current.type != TokenType.eof) {
            auto stmt = collectStatement();
            if (stmt.statementType.length == 0) break;
            result.statements ~= stmt;
        }

        return result;
    }
}
