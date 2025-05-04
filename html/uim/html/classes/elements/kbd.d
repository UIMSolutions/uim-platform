/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.kbd;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Kbd : DH5Obj {
	mixin(H5This!"kbd");
}
mixin(H5Short!"Kbd");

unittest {
  testH5Obj(H5Kbd, "kbd");
}
