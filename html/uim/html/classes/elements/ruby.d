/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ruby;

mixin(Version!("test_uim_html"));

import uim.html; 
@safe:

class DH5Ruby : DH5Obj {
	mixin(H5This!"ruby");
}
mixin(H5Short!"Ruby");

unittest {
    testH5Obj(H5Ruby, "ruby");
}
