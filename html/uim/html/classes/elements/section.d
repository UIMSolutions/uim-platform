module uim.html.classes.elements.section;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Section : DH5Obj {
	mixin(H5This!("section"));
}
mixin(H5Short!"Section");

unittest {
    testH5Obj(H5Section, "section");
}}
