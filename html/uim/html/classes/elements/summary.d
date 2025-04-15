module uim.html.classes.elements.summary;

import uim.html;
@safe:

class DH5Summary : DH5Obj {
	mixin(H5This!"summary");
}
mixin(H5Short!"Summary");

unittest {
    assert(H5Summary == "<summary></summary>");
}}
