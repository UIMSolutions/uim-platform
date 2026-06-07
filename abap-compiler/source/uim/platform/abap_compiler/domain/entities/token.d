/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.domain.entities.token;

import uim.platform.abap_compiler;

// mixin(ShowModule!());
@safe:

/// A single lexical unit produced by the ABAP lexer.
/// Corresponds to the ABAP concept of a "Token" in the syntax tree.
struct Token {
    TokenId   id;        /// Ordinal position in source
    TokenType type;      /// Lexical category
    string    value;     /// Raw text value as it appears in source
    size_t    line;      /// 1-based source line
    size_t    column;    /// 1-based column within line

    Json toJson() const {
        return Json.emptyObject
            .set("id",     id.value)
            .set("type",   to!string(type))
            .set("value",  value)
            .set("line",   cast(long) line)
            .set("column", cast(long) column);
    }
}
