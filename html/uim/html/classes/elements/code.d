/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.code;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for code tag - displays its contents styled in a fashion intended to indicate that the text is a short fragment of computer code.
class DH5Code : DH5Obj {
	mixin(H5This!"code");
}
mixin(H5Short!"Code");

unittest {
  testH5Obj(H5Code, "code");
}
