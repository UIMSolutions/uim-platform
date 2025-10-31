/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.rt;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <rt> HTML element specifies the pronunciation of characters (for East Asian typography) presented in a <ruby> element.
class DH5Rt : DH5Obj {
	mixin(H5This!"rt");
}
mixin(H5Short!"Rt");

unittest {
  testH5Obj(H5Rt, "rt");
}
