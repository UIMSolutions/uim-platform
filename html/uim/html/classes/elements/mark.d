/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.mark;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <mark> HTML element represents text highlighted for reference purposes, due to its relevance in a particular context.
class DH5Mark : DH5Obj {
	mixin(H5This!"Mark");
}
mixin(H5Short!"Mark");

unittest {
  testH5Obj(H5Mark, "mark");
}
