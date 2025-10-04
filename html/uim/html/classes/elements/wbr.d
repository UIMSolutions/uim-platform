module uim.html.classes.elements.wbr;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Wbr : DH5Obj {
	mixin(H5This!"wbr");
}
mixin(H5Short!"Wbr");

unittest {
	testH5Obj(H5Wbr, "wbr");
}
