/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.th;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <th> HTML element defines a header cell in an HTML table.
class DH5Th : DH5Obj {
	mixin(H5This!"th");
}
mixin(H5Calls!("H5Th", "DH5Th"));

unittest {
  testH5Obj(H5Th, "th");
}
