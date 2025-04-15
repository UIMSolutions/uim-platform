module uim.html.classes.elements.output;

import uim.html;
@safe:

class DH5Output : DH5Obj {
	mixin(H5This!"output");
}
mixin(H5Short!"Output");

unittest {
  testH5Obj(H5Output, "output");
}}
