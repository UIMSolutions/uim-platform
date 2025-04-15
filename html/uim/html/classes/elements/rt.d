module uim.html.classes.elements.rt;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Rt : DH5Obj {
	mixin(H5This!"rt");
}
mixin(H5Short!"Rt");

unittest {
  testH5Obj(H5Rt, "rt");
}}
