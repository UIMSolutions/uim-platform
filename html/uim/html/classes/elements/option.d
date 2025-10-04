/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.option;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Option : DH5Obj {
	mixin(H5This!"option");

	mixin(MyAttribute!("disabled", "disabled"));
	mixin(MyAttribute!("selected", "selected"));
	mixin(MyAttribute!("value", "value"));
}
mixin(H5Short!"Option");

enum option_modes : string {
	Default = "",
	Selected = "selected",
	Disabled = "disabled"
}

unittest {
  testH5Obj(H5Option, "option");
	// mixin(testH5DoubleAttributes!("H5Option", "option", ["disabled", "selected", "value"]));
}

