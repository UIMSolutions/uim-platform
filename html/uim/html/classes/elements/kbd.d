module uim.html.classes.elements.kbd;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Kbd : DH5Obj {
	mixin(H5This!"kbd");
}
mixin(H5Short!"Kbd");

unittest {
  testH5Obj(H5Kbd, "kbd");
}
