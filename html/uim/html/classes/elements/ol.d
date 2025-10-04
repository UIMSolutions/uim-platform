/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.ol;

import uim.html;
mixin(Version!("test_uim_html"));

@safe:

class DH5Ol : DH5Obj {
  mixin(H5This!"ol");

<<<<<<< HEAD
	mixin(MyContent!("item", "H5Li"));
	unittest {
		assert(H5Ol.item == "<ol><li></li></ol>");
	}}
}
mixin(H5Short!"Ol");
=======
  mixin(MyContent!("item", "H5Li"));
  unittest {
    assert(H5Ol.item == "<ol><li></li></ol>");
  }
}
mixin(H5Short!"Ol");

>>>>>>> 8504c0aa77a642ca4cdfc94f5177dce259b60200
unittest {
  testH5Obj(H5Ol, "ol");
}
