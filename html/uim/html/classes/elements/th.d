module uim.html.classes.elements.th;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Th : DH5Obj {
	mixin(H5This!"th");
}
mixin(H5Calls!("H5Th", "DH5Th"));

unittest {
  testH5Obj(H5Th, "th");
}}
