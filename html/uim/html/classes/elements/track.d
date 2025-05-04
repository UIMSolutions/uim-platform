/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.track;

mixin(Version!("test_uim_html"));

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Track : DH5Obj {
	mixin(H5This!"track");
	
	mixin(MyAttribute!("isDefault", "default"));
  mixin(MyAttribute!"label");
  mixin(MyAttribute!"src");
  mixin(MyAttribute!"srclang");
}
mixin(H5Short!"Track");

unittest {
  testH5Obj(H5Track, `track`);

	// mixin(testH5DoubleAttributes!("H5Track", "track", ["label", "src", "srclang"]));
}
