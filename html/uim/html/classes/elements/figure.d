/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.figure;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <figure> HTML element is used to encapsulate media content, such as images, illustrations, diagrams, or code snippets, along with an optional caption provided by the <figcaption> element. It is typically used to group related content and provide semantic meaning to the media within a document.
class DH5Figure : DH5Obj {
	mixin(H5This!"figure");
}
mixin(H5Short!"Figure");

unittest {
  testH5Obj(H5Figure, "figure");
}
