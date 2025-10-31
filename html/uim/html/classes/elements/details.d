/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.details;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <details> HTML element creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state.
class DH5Details: DH5Obj {
	mixin(H5This!"details");
}
mixin(H5Short!"Details");

unittest {
  testH5Obj(H5Details, "details");
}
