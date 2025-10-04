module uim.html.classes.elements.section;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Section : DH5Obj {
	mixin(H5This!("section"));
}
mixin(H5Short!"Section");

unittest {
    testH5Obj(H5Section, "section");
}}
