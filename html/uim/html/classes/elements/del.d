/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.del;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <del> HTML element represents a range of text that has been deleted from a document.
class DH5Del : DH5Obj {
	mixin(H5This!"del");
}
mixin(H5Short!"Del");

unittest {
  testH5Obj(H5Del, "del");
}
