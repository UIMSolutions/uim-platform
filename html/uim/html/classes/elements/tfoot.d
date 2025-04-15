/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.tfoot;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Tfoot : DH5Obj {
	mixin(H5This!"tfoot");

	// Adding a row <tr>
	mixin(MyContent!("tr", "H5Tr"));
	// Adding a row <tr>
	mixin(MyContent!("row", "H5Tr"));
}
mixin(H5Short!"Tfoot");

unittest {
	testH5Obj(H5Tfoot, "tfoot");
	assert(H5Tfoot.tr == "<tfoot><tr></tr></tfoot>");
	assert(H5Tfoot.row == "<tfoot><tr></tr></tfoot>");
	assert(H5Tfoot.tr.tr == "<tfoot><tr></tr><tr></tr></tfoot>");
	assert(H5Tfoot.row.row == "<tfoot><tr></tr><tr></tr></tfoot>");
	assert(H5Tfoot.tr.row == "<tfoot><tr></tr><tr></tr></tfoot>");
	assert(H5Tfoot.row.tr == "<tfoot><tr></tr><tr></tr></tfoot>");
}
