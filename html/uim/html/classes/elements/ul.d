﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ul;

mixin(Version!("test_uim_html"));

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Ul : DH5Obj {
	mixin(H5This!"ul");

	mixin(MyContent!("li", "H5Li"));
	mixin(MyContent!("item", "H5Li"));
	mixin(MyContent!("link", "this.item", "H5Li"));

	O link(this O)(string id, string[] linkClasses, string src, string title) {
		this.item(id, linkClasses, ["src":src], title); return cast(O)this;
	}
}
mixin(H5Short!"Ul");

unittest {
	testH5Obj(H5Ul, "ul");
	assert(H5Ul.item == "<ul><li></li></ul>");
	assert(H5Ul.item.item == "<ul><li></li><li></li></ul>");
	assert(H5Ul.item(["test"]) == `<ul><li class="test"></li></ul>`);
	assert(H5Ul.li == "<ul><li></li></ul>");
	assert(H5Ul(`<li></li>`) == "<ul><li></li></ul>");
	assert(H5Ul(H5Li) == "<ul><li></li></ul>");
	assert(H5Ul(H5.li) == "<ul><li></li></ul>");
}}
