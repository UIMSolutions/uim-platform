/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.services.lexer;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// Pure domain service: tokenises ABAP source code.
/// Implements the ABAP lexical rules for Release 7.51 as documented on
/// https://help.sap.com/doc/abapdocu_751_index_htm/7.51/de-DE/abenabap_overview.htm
///
/// Recognised constructs:
///   - Keywords (DATA, CLASS, METHOD, WRITE, SELECT, …)
///   - Identifiers, integer and string literals
///   - Chain colon ':', period statement terminator '.'
///   - Comments introduced by '"' or '*' at column 1
///   - Operators: + - * / = < > <= >= <> && ||
struct AbapLexer {
    // ---------------------------------------------------------------------------
    // ABAP 7.51 keyword set (core subset sufficient for parsing class pools,
    // function groups, reports, and ABAP Objects — see ABAP keyword documentation)
    // ---------------------------------------------------------------------------
    private static immutable string[] KEYWORDS = [
        "ABAP", "ADD", "AND", "APPEND", "ASSIGN", "AT",
        "BEGIN", "BETWEEN", "BY",
        "CALL", "CASE", "CHECK", "CLASS", "CLASS-DATA", "CLASS-METHODS",
        "CLEAR", "CLOSE", "COLLECT", "COMMIT", "COMPUTE", "CONDENSE",
        "CONTINUE", "CREATE", "CURSOR",
        "DATA", "DEFINE", "DELETE", "DESCRIBE", "DO",
        "ELSE", "ELSEIF", "END", "ENDCASE", "ENDCLASS", "ENDDO",
        "ENDFORM", "ENDFUNCTION", "ENDIF", "ENDINTERFACE", "ENDLOOP",
        "ENDMETHOD", "ENDMODULE", "ENDSELECT", "ENDTRY", "ENDWHILE",
        "EXIT", "EXPORT",
        "FETCH", "FIELD", "FIELD-SYMBOLS", "FIND", "FORM", "FREE",
        "FROM", "FUNCTION", "FUNCTION-POOL",
        "GET",
        "IF", "IMPLEMENTATION", "IMPORT", "IN", "INCLUDE", "INTERFACE",
        "INTO", "IS",
        "LIKE", "LOOP",
        "MESSAGE", "METHOD", "METHODS", "MODIFY", "MOVE",
        "NEW", "NOT",
        "OBJECT", "OF", "ON", "OPEN", "OR", "OUT",
        "PERFORM", "PROGRAM", "PUBLIC",
        "RAISE", "READ", "REFRESH", "REJECT", "REPLACE", "REPORT",
        "RETURN", "ROLLBACK",
        "SECTION", "SELECT", "SET", "SORT", "SPLIT", "START-OF-SELECTION",
        "STATIC", "SUBMIT", "SUBTRACT", "SYSTEM-CALL",
        "TABLE", "TABLES", "TRANSLATE", "TRY", "TYPE", "TYPES",
        "UPDATE",
        "VALUE",
        "WHERE", "WHILE", "WITH", "WORK", "WRITE",
        "XSDBOOL",
    ];

    private static bool isKeyword(string word) {
        import std.uni : toUpper;
        immutable up = word.toUpper;
        foreach (k; KEYWORDS)
            if (k == up) return true;
        return false;
    }

    // ---------------------------------------------------------------------------
    // Tokenise
    // ---------------------------------------------------------------------------
    Token[] tokenise(string source) @safe {
        Token[] tokens;
        size_t  pos    = 0;
        size_t  line   = 1;
        size_t  col    = 1;
        size_t  idx    = 0;

        void advance(size_t n = 1) @safe {
            foreach (i; 0 .. n) {
                if (pos < source.length) {
                    if (source[pos] == '\n') { line++; col = 1; }
                    else col++;
                    pos++;
                }
            }
        }

        char current() @safe {
            return pos < source.length ? source[pos] : '\0';
        }

        char peek(size_t ahead = 1) @safe {
            return (pos + ahead) < source.length ? source[pos + ahead] : '\0';
        }

        while (pos < source.length) {
            size_t tokLine = line;
            size_t tokCol  = col;
            char   c       = current();

            // --- Newline
            if (c == '\n') {
                tokens ~= Token(TokenId(idx++), TokenType.newline, "\n", tokLine, tokCol);
                advance();
                continue;
            }

            // --- Whitespace
            if (c == ' ' || c == '\t' || c == '\r') {
                advance();
                continue;
            }

            // --- Line comment: '*' at column 1
            if (c == '*' && col == 1) {
                size_t start = pos;
                while (pos < source.length && source[pos] != '\n') advance();
                tokens ~= Token(TokenId(idx++), TokenType.comment, source[start .. pos], tokLine, tokCol);
                continue;
            }

            // --- Inline comment: '"'
            if (c == '"') {
                size_t start = pos;
                advance();
                while (pos < source.length && source[pos] != '\n') advance();
                tokens ~= Token(TokenId(idx++), TokenType.comment, source[start .. pos], tokLine, tokCol);
                continue;
            }

            // --- String literal: 'text' or `text`
            if (c == '\'' || c == '`') {
                char   delim = c;
                size_t start = pos;
                advance();
                while (pos < source.length && source[pos] != delim) {
                    if (source[pos] == '\\') advance();
                    advance();
                }
                advance(); // closing delimiter
                tokens ~= Token(TokenId(idx++), TokenType.literal_string, source[start .. pos], tokLine, tokCol);
                continue;
            }

            // --- Numeric literal
            if (c >= '0' && c <= '9') {
                size_t start = pos;
                while (pos < source.length && source[pos] >= '0' && source[pos] <= '9') advance();
                tokens ~= Token(TokenId(idx++), TokenType.literal_integer, source[start .. pos], tokLine, tokCol);
                continue;
            }

            // --- Identifier or keyword (includes hyphenated names like CLASS-DATA)
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_' || c == '/') {
                size_t start = pos;
                while (pos < source.length) {
                    char nc = source[pos];
                    if ((nc >= 'A' && nc <= 'Z') || (nc >= 'a' && nc <= 'z') ||
                        (nc >= '0' && nc <= '9') || nc == '_' || nc == '-' || nc == '/')
                        advance();
                    else
                        break;
                }
                string word = source[start .. pos];
                tokens ~= Token(TokenId(idx++), isKeyword(word) ? TokenType.keyword : TokenType.identifier,
                                word, tokLine, tokCol);
                continue;
            }

            // --- Operators / punctuation
            switch (c) {
                case '.':
                    tokens ~= Token(TokenId(idx++), TokenType.period,   ".", tokLine, tokCol); advance(); break;
                case ',':
                    tokens ~= Token(TokenId(idx++), TokenType.comma,    ",", tokLine, tokCol); advance(); break;
                case ':':
                    tokens ~= Token(TokenId(idx++), TokenType.colon,    ":", tokLine, tokCol); advance(); break;
                case '(':
                    tokens ~= Token(TokenId(idx++), TokenType.lparen,   "(", tokLine, tokCol); advance(); break;
                case ')':
                    tokens ~= Token(TokenId(idx++), TokenType.rparen,   ")", tokLine, tokCol); advance(); break;
                default:
                    // Two-char operators
                    string twoChar = pos + 1 < source.length ? source[pos .. pos + 2] : "";
                    if (twoChar == "<=" || twoChar == ">=" || twoChar == "<>" ||
                        twoChar == "&&" || twoChar == "||") {
                        tokens ~= Token(TokenId(idx++), TokenType.operator, twoChar, tokLine, tokCol);
                        advance(2);
                    } else {
                        tokens ~= Token(TokenId(idx++), TokenType.operator, source[pos .. pos + 1], tokLine, tokCol);
                        advance();
                    }
                    break;
            }
        }

        tokens ~= Token(TokenId(idx), TokenType.eof, "", line, col);
        return tokens;
    }
}
