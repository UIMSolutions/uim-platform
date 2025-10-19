/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ol;

import uim.html;
mixin(Version!("test_uim_html"));

@safe:

// The <ol> HTML element represents an ordered list of items, where each item is typically displayed with a numerical or alphabetical marker. The <ol> element is used to group related items in a specific sequence, indicating that the order of the items is significant. Each item within the list is defined using the <li> (list item) element. Ordered lists are commonly used for instructions, rankings, or any situation where the order of items matters.
class DH5Ol : DH5Obj {
  mixin(H5This!"ol");

  mixin(MyContent!("item", "H5Li"));
  unittest {
    assert(H5Ol.item == "<ol><li></li></ol>");
  }
}
mixin(H5Short!"Ol");

unittest {
  testH5Obj(H5Ol, "ol");
}