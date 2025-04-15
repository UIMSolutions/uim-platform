module uim.html.classes.elements.noscript;

import uim.html;
@safe:

class DH5Noscript : DH5Obj {
	mixin(H5This!("noscript"));
}
mixin(H5Short!"Noscript");

unittest {
    assert(H5Noscript == "<noscript></noscript>");
}}
