module uim.html.classes.elements.em;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Em: DH5Obj {
	mixin(H5This!"em");
}
mixin(H5Short!"Em");

unittest {
  testH5Obj(H5Em, "em");
}}