﻿module uim.html.classes.elements.dfn;

import uim.html;
@safe:

class DH5Dfn : DH5Obj {
	mixin(H5This!"dfn");
}
mixin(H5Short!"Dfn");

version(test_uim_html) { unittest {
  testH5Obj(H5Dfn, "dfn");
}}
