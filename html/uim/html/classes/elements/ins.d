/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ins;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <ins> - represents a range of text that has been added to a document.
class DH5Ins : DH5Obj {
	mixin(H5This!"ins");
}
mixin(H5Short!"Ins");

unittest {
    testH5Obj(H5Ins, "ins");
}
