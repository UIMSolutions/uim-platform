/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.fieldset;

import uim.html;
@safe:

class DH5Fieldset : DH5Obj {
	mixin(H5This!"fieldset");
}
mixin(H5Short!"Fieldset");

unittest {
  testH5Obj(H5Fieldset, "fieldset");
}
