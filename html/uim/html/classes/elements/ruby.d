module uim.html.classes.elements.ruby;

mixin(Version!("test_uim_html"));

import uim.html; 
@safe:

class DH5Ruby : DH5Obj {
	mixin(H5This!"ruby");
}
mixin(H5Short!"Ruby");

unittest {
    testH5Obj(H5Ruby, "ruby");
}
