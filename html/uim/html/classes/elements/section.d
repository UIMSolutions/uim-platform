/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.section;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <section> HTML element represents a standalone section — which doesn't have a more specific semantic element to represent it — contained within an HTML document.
class DH5Section : DH5Obj {
	mixin(H5This!("section"));
}
mixin(H5Short!"Section");

unittest {
    testH5Obj(H5Section, "section");
}
