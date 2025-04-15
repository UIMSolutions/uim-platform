module uim.html.classes.elements.noscript;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Noscript : DH5Obj {
	mixin(H5This!("noscript"));
}
mixin(H5Short!"Noscript");

unittest {
    assert(H5Noscript == "<noscript></noscript>");
}
