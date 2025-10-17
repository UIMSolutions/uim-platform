/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.sup;

import uim.html;
@safe:

// Wrapper for <sup> - specifies inline text which is to be displayed as superscript for solely typographical reasons. 
class DH5Sup : DH5Obj {
	mixin(H5This!"sup");
}
mixin(H5Short!"Sup");

unittest {
    assert(H5Sup == "<sup></sup>");
}
