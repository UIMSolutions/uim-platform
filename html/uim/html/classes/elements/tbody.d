/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.html.classes.elements.tbody;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <tbody> HTML element represents the body content of a table.
class DH5Tbody : DH5Obj {
  mixin(H5This!"tbody");

  mixin(MyContent!("tr", "H5Tr"));
  unittest {
    assert(H5Tbody.tr == "<tbody><tr></tr></tbody>");
  }
}

mixin(MyContent!("row", "H5Tr"));
unittest {
  assert(H5Tbody.row == "<tbody><tr></tr></tbody>");
}
mixin(H5Short!"Tbody");
unittest {
  assert(H5Tbody == "<tbody></tbody>");
}
