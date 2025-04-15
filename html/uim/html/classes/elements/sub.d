module uim.html.classes.elements.sub;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Sub : DH5Obj {
	mixin(H5This!"sub");
}
mixin(H5Short!"Sub");

unittest {
  testH5Obj(H5Sub, "sub");
}}
