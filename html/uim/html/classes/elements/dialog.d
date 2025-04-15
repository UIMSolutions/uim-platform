module uim.html.classes.elements.dialog;

import uim.html;
@safe:

class DH5Dialog : DH5Obj {
	mixin(H5This!"dialog");
}
mixin(H5Short!"Dialog");

unittest {
  testH5Obj(H5Dialog, "dialog");
}}
