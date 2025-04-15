module uim.html.classes.elements.data;

import uim.html;
@safe:

class DH5Data : DH5Obj {
	mixin(H5This!"data");
}
mixin(H5Short!"Data");

unittest {
  testH5Obj(H5Data, "data");
}}
