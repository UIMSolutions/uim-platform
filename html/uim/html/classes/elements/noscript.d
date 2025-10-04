/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.noscript;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Noscript : DH5Obj {
	mixin(H5This!("noscript"));
}
mixin(H5Short!"Noscript");

unittest {
    assert(H5Noscript == "<noscript></noscript>");
}
