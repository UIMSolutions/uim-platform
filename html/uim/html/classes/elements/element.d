module uim.html.classes.elements.element;

import uim.html;
@safe:

class DH5Element : DH5Obj {
	mixin(H5This!"element");
}
mixin(H5Short!"Element");

unittest {
	assert(H5Element, "element");
}}