/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.datalist;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <datalist> HTML element contains a set of <option> elements that represent the permissible or recommended options available to users in other controls. It is typically used in conjunction with an <input> element to provide autocomplete functionality.
class DH5Datalist : DH5Obj {
	mixin(H5This!"datalist");

	mixin(MyContent!("option", "H5Option"));
}
mixin(H5Short!"Datalist");

unittest {
  testH5Obj(H5Datalist, "datalist");
}
