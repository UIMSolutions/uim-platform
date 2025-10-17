/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.dfn;

import uim.html;
@safe:

class DH5Dfn : DH5Obj {
	mixin(H5This!"dfn");
}
mixin(H5Short!"Dfn");

unittest {
  testH5Obj(H5Dfn, "dfn");
}}
