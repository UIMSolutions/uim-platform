module uim.html.classes.elements.dt;

import uim.html;
@safe:

class DH5Dt : DH5Obj {
	mixin(H5This!"dt");
}
mixin(H5Short!"Dt");

unittest {
  testH5Obj(H5Dt, "dt");
}}