module uim.html.classes.elements.var;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Var : DH5Obj {
	mixin(H5This!"var");
}
mixin(H5Short!"Var");

unittest {
    assert(H5Var,"<var></var>");
}}
