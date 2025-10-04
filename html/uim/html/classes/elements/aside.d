/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.aside;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// Wrapper for aside tag - represents a portion of a document whose content is only indirectly related to the document's main content. 
// Asides are frequently presented as sidebars or call-out boxes.
class DH5Aside : DH5Obj {
	mixin(H5This!"aside");
}
mixin(H5Short!"Aside");

unittest {
  testH5Obj(H5Aside, "aside");
  assert(H5Aside == `<aside></aside>`);
}
