﻿module uim.html.classes.elements.svg;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Svg : DH5Obj {
	mixin(H5This!"svg");
}
mixin(H5Short!"Svg");

unittest {
    assert(H5Svg == "<svg></svg>");
}}
