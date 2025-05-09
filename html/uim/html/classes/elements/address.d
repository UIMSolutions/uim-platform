﻿module uim.html.classes.elements.address;

import uim.html;
@safe:

// Wrapper for <address> - indicates that the enclosed HTML provides contact information for a person or people, or for an organization.
class DH5Address : DH5Obj {
	mixin(H5This!"address");
}
mixin(H5Short!"Address");

unittest {
	testH5Obj(H5Address, "address");

  assert(H5Address = `<address></address>`);
}}

