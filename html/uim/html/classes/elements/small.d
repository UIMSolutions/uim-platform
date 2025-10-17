/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.small;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// Wrapper for <small> - represents side-comments and small print, like copyright and legal text, independent of its styled presentation.
class DH5Small : DH5Obj {
	mixin(H5This!"small");
}
mixin(H5Short!"Small");

unittest {
    testH5Obj(H5Small, "small");
}}

