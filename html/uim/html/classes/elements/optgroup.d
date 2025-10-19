/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.optgroup;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Optgroup : DH5Obj {
  mixin(H5This!"optgroup");

  //	O option(this O)() {
  //
  //	}
}

mixin(H5Short!"Optgroup");

unittest {
  testH5Obj(H5Optgroup, "optgroup");
}