/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.figcaption;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <figcaption> HTML element is used to provide a caption or description for a <figure> element. It is typically placed as the first or last child of the <figure> element and helps to explain or contextualize the content within the figure, such as images, illustrations, or diagrams.
class DH5Figcaption : DH5Obj {
	mixin(H5This!"figcaption");
}
mixin(H5Short!"Figcaption");

unittest {
  testH5Obj(H5Figcaption, "figcaption");
}
