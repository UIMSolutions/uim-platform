module uim.html.classes.elements.rp;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Rp : DH5Obj {
	mixin(H5This!"rp");
}
mixin(H5Short!"Rp");

unittest {
    assert(H5Rp == "<rp></rp>");
}