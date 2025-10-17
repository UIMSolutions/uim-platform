/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.title;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Title : DH5Obj {
	mixin(H5This!("title"));
}
mixin(H5Short!"Title");

unittest {
  testH5Obj(H5Title, "title");
  // mixin(testH5DoubleClasses!("H5Title", "title"));
}
