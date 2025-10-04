/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.legend;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// Wrapper for <legend> - represents a caption for the content of its parent <fieldset>.
class DH5Legend : DH5Obj {
	mixin(H5This!"legend");
}
mixin(H5Short!"Legend");

unittest {
  testH5Obj(H5Legend, "legend");
}
