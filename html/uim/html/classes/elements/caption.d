/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.caption;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for caption tag = specifies the caption (or title) of a table. 
class DH5Caption : DH5Obj {
	mixin(H5This!"caption");
}
mixin(H5Short!"Caption");

unittest {
  assert(H5Caption == "<caption></caption>");
}
