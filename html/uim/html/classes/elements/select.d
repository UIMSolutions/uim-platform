/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.select;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Select : DH5Obj {
	mixin(H5This!"select");

	mixin(TProperty!("string", "selected"));
	mixin(TProperty!("STRINGAA", "options"));
	mixin(TProperty!("bool", "sorted"));

	mixin(MyContent!("option", "H5Option"));

}
mixin(H5Short!"Select");

unittest {
	testH5Obj(H5Select, "select");
	
	assert(H5Select.option(["value":"aValue"]) == `<select><option value="aValue"></option></select>`);
	assert(H5Select.option(["value":"aValue"], "someContent") == `<select><option value="aValue">someContent</option></select>`);
}}
