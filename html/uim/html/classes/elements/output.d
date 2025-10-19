module uim.html.classes.elements.output;

import uim.html;
@safe:

// The <output> HTML element represents the result of a calculation or user action.
class DH5Output : DH5Obj {
	mixin(H5This!"output");
}
mixin(H5Short!"Output");

unittest {
  testH5Obj(H5Output, "output");
}
