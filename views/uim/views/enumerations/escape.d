/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.enumerations.escape;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

enum HTMLEscapes : string {
    NONE = "none",
    MINIMAL = "minimal",
    NEWLINE = "newline",
    QUOTES = "quotes"
}	

HTMLEscapeFlags toVibe(HTMLEscapes escape) {
    switch (escape) {
        case HTMLEscapes.MINIMAL: return HTMLEscapeFlags.escapeMinimal;
        case HTMLEscapes.NEWLINE: return HTMLEscapeFlags.escapeNewline;
        case HTMLEscapes.QUOTES: return HTMLEscapeFlags.escapeQuotes;
        default: return HTMLEscapeFlags.escapeUnknown; 
    }
}

HTMLEscapes fromVibe(HTMLEscapeFlags escape) {
    switch (escape) {
        case HTMLEscapeFlags.escapeMinimal: return HTMLEscapes.MINIMAL;
        case HTMLEscapeFlags.escapeNewline: return HTMLEscapes.NEWLINE;
        case HTMLEscapeFlags.escapeQuotes: return HTMLEscapes.QUOTES;
        default: return HTMLEscapes.NONE; 
    }
}