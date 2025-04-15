module uim.html.classes.elements.datalist;

import uim.html;
@safe:

class DH5Datalist : DH5Obj {
	mixin(H5This!"datalist");

	mixin(MyContent!("option", "H5Option"));
}
mixin(H5Short!"Datalist");

unittest {
  testH5Obj(H5Datalist, "datalist");
} }
