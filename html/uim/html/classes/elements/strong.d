/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.strong;

mixin(Version!("test_uim_html"));

import uim.html; 
@safe:

// Wrapper for <strong> -  indicates that its contents have strong importance, seriousness, or urgency. 
class DH5Strong : DH5Obj {
	mixin(H5This!"strong");
}
mixin(H5Short!"Strong");

unittest {
    assert(H5Strong == "<strong></strong>");
}
