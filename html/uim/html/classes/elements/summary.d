/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.summary;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Summary : DH5Obj {
	mixin(H5This!"summary");
}
mixin(H5Short!"Summary");

unittest {
    assert(H5Summary == "<summary></summary>");
}
