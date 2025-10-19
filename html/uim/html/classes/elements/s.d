/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.s;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <s> HTML element renders text with a strikethrough, or a line through it, to indicate that the text is no longer relevant or accurate.
class DH5S : DH5Obj {
  mixin(H5This!"s");
}

mixin(H5Short!"S");

unittest {
  testH5Obj(H5S, "s");
}
