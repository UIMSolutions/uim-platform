﻿module uim.html.classes.elements.details;

import uim.html;
@safe:

class DH5Details: DH5Obj {
	mixin(H5This!"details");
}
mixin(H5Short!"Details");

unittest {
  testH5Obj(H5Details, "details");
}}
