/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.dt;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <dt> HTML element is used to specify a term or name in a description list. It is typically paired with the <dd> element, which provides the definition or description of the term defined by the <dt> element.
class DH5Dt : DH5Obj {
	mixin(H5This!"dt");
}
mixin(H5Short!"Dt");

unittest {
  testH5Obj(H5Dt, "dt");
}