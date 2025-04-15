/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.figure;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for the figure tag - represents self-contained content, potentially with an optional caption, which is specified using the <figcaption> element.
class DH5Figure : DH5Obj {
	mixin(H5This!"figure");
}
mixin(H5Short!"Figure");

unittest {
  testH5Obj(H5Figure, "figure");
}
