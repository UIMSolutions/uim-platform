module uim.html.classes.elements.menu;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Menu : DH5Obj {
	mixin(H5This!"menu");
}
mixin(H5Short!"Menu");

unittest {
  testH5Obj(H5Menu, "menu");
}}
