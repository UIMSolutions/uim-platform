/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.dd;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <dd> HTML element is used to describe a term or name in a description list. It provides the definition or value associated with the preceding <dt> (definition term) element.
class DH5Dd : DH5Obj {
	mixin(H5This!"dd");
}
mixin(H5Short!"Dd");

unittest {
  testH5Obj(H5Dd, "dd");
}
