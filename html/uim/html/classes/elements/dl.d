/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.dl;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <dl> HTML element represents a description list, which is used to group together terms and their corresponding descriptions. It consists of pairs of <dt> (definition term) and <dd> (definition description) elements, allowing for a structured presentation of information.
class DH5Dl : DH5Obj {
	mixin(H5This!"dl");
}
mixin(H5Short!"Dl");

unittest {
  testH5Obj(H5Dl, "dl");
}
