﻿module uim.html.classes.elements.u;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5U : DH5Obj {
	mixin(H5This!"u");
}
mixin(H5Short!"U");

unittest {
   testH5Obj(H5U, "u");
}}
