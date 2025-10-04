module uim.html.classes.elements.title;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Title : DH5Obj {
	mixin(H5This!("title"));
}
mixin(H5Short!"Title");

unittest {
  testH5Obj(H5Title, "title");
  // mixin(testH5DoubleClasses!("H5Title", "title"));
}}
