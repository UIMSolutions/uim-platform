/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.rp;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <rp> HTML element is used to provide fall-back parentheses for browsers that do not support ruby annotations.
class DH5Rp : DH5Obj {
	mixin(H5This!"rp");
}
mixin(H5Short!"Rp");

unittest {
    assert(H5Rp == "<rp></rp>");
}