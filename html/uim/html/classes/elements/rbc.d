﻿module uim.html.classes.elements.rbc;

import uim.html;
@safe:

class DH5Rbc : DH5Obj {
	mixin(H5This!"rbc");
}
mixin(H5Short!"Rbc");

version(test_uim_html) { unittest {
    assert(H5Rbc == "<rbc></rbc>");
}}
