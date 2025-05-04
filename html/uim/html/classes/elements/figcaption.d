/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.figcaption;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for figcaption tag - represents a caption or legend describing the rest of the contents of its parent <figure> element.
class DH5Figcaption : DH5Obj {
	mixin(H5This!"figcaption");
}
mixin(H5Short!"Figcaption");

unittest {
  testH5Obj(H5Figcaption, "figcaption");
}}
