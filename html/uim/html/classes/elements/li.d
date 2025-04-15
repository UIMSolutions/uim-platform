/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.li;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <li> - represent an item in a list.
class DH5Li : DH5Obj {
	mixin(H5This!"li");
}
mixin(H5Short!"Li");

unittest {
  testH5Obj(H5Li, "li");
}}
