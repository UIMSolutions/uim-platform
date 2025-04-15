/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.template_;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <template> - s a mechanism for holding HTML that is not to be rendered immediately when a page is loaded but may be instantiated subsequently during runtime using JavaScript.
class DH5Template : DH5Obj {
	mixin(H5This!"template");
}
mixin(H5Short!"Template");

unittest {
    assert(H5Template == "<template></template>");
}
