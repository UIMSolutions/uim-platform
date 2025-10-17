/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.td;

import uim.html;
@safe:

class DH5Td : DH5Obj {
	mixin(H5This!"td");
}
mixin(H5Short!"Td");

unittest {
  testH5Obj(H5Td, "td");
}
