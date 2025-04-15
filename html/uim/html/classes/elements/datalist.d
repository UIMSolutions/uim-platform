/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.datalist;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Datalist : DH5Obj {
	mixin(H5This!"datalist");

	mixin(MyContent!("option", "H5Option"));
}
mixin(H5Short!"Datalist");

unittest {
  testH5Obj(H5Datalist, "datalist");
}
