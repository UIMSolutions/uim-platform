module uim.html.classes.elements.progress;

import uim.html;
@safe:

class DH5Progress : DH5Obj {
	mixin(H5This!"progress");
}
mixin(H5Short!"Progress");

unittest {
    assert(H5Progress == "<progress></progress>");
}}
