/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.cite;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// Wrapper for cite tag - used to describe a reference to a cited creative work, and must include the title of that work. 
class DH5Cite : DH5Obj {
	mixin(H5This!"cite");
}
mixin(H5Short!"Cite");

unittest {
  assert(H5Cite);
  assert(H5Cite == "<cite></cite>");
}

