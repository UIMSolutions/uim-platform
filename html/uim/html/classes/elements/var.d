/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.var;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Var : DH5Obj {
	mixin(H5This!"var");
}
mixin(H5Short!"Var");

unittest {
    assert(H5Var,"<var></var>");
}
