/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.tr;

mixin(Version!("test_uim_html"));

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Tr : DH5Obj {
	mixin(H5This!"tr");

	mixin(MyContent!("th", "H5Th"));
	unittest {
			assert(H5Tr.th, "<tr><th></th></tr>");
	}}

	mixin(MyContent!("td", "H5Td"));
	mixin(MyContent!("cell", "H5Td"));
}
mixin(H5Calls!("H5Tr", "DH5Tr"));

unittest {
    testH5Obj(H5Tr, "tr");
		assert(H5Tr.td == "<tr><td></td></tr>");
		assert(H5Tr.cell == "<tr><td></td></tr>");
		assert(H5Tr(H5Td) == "<tr><td></td></tr>");
		assert(H5Tr(H5Td, H5Td) == "<tr><td></td><td></td></tr>");
		assert(H5Tr.td == "<tr><td></td></tr>");
		assert(H5Tr.cell == "<tr><td></td></tr>");
		assert(H5Tr.td.td == "<tr><td></td><td></td></tr>");
		assert(H5Tr.cell.cell == "<tr><td></td><td></td></tr>");
}}
