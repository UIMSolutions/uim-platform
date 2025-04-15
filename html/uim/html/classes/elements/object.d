module uim.html.classes.elements.object;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Object : DH5Obj {
	mixin(H5This!"object");
}
mixin(H5Short!"Object");

unittest {
    assert(H5Object == "<object></object>");
}}
