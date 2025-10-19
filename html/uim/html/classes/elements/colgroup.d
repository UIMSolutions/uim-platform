/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.colgroup;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <colgroup> HTML element defines a group of one or more columns in a table for formatting. It is used to apply styles or attributes to entire columns, such as width or background color.
class DH5Colgroup : DH5Obj {
	mixin(H5This!"Colgroup");
}
mixin(H5Short!"Colgroup");

unittest {
  testH5Obj(H5Colgroup, "colgroup");
}
