/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.mark;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <mark> - represents text which is marked or highlighted for reference or notation purposes, due to the marked passage's relevance or importance in the enclosing context.
class DH5Mark : DH5Obj {
	mixin(H5This!"Mark");
}
mixin(H5Short!"Mark");

unittest {
  testH5Obj(H5Mark, "mark");
}
