/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.comment;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <comment> HTML element is used to insert comments in the HTML code. These comments are not displayed in the browser but can be useful for developers to leave notes or explanations within the code.
class DH5Comment : DH5Obj {
	mixin(H5This!"comment");

	override string toString() {
//		auto content = "";
//		foreach(obj; objects) content ~= obj.toString;
//		return   "<!-- %s -->".format(content);
		return super.toString;
	}
}
mixin(H5Short!"Comment");

unittest {
  testH5Obj(H5Comment, "comment");
}}
