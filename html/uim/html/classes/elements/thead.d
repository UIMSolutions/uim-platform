/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.thead;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <thead> HTML element represents a group of introductory or navigational aids in a table.
class DH5Thead : DH5Obj {
  mixin(H5This!"thead");

  mixin(MyContent!("tr", "H5Tr"));
  mixin(MyContent!("row", "H5Tr"));
}

mixin(H5Short!"Thead");

unittest {
  testH5Obj(H5Thead, "thead");
  assert(H5Thead.tr == "<thead><tr></tr></thead>");
  assert(H5Thead.row == "<thead><tr></tr></thead>");
}
