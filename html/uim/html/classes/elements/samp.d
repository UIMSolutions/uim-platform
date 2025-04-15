module uim.html.classes.elements.samp;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Samp : DH5Obj {
	mixin(H5This!"samp");
}
mixin(H5Short!"Samp");

unittest {
    assert(H5Samp,"<samp></samp>");
}}
