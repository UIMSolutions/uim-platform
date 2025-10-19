module uim.html.classes.elements.picture;

import uim.html;
@safe:

// The <picture> HTML element contains zero or more <source> elements and one <img> element to provide versions of an image for different display/device scenarios.
class DH5Picture : DH5Obj {
	mixin(H5This!"picture");
}
mixin(H5Short!"Picture");

unittest {
    testH5Obj(H5Picture, "picture");
}
