﻿module uim.html.classes.elements.tbody;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Tbody : DH5Obj {
	mixin(H5This!"tbody");
	
	mixin(MyContent!("tr", "H5Tr"));
	unittest {
			assert(H5Tbody.tr == "<tbody><tr></tr></tbody>");
	}}

	mixin(MyContent!("row", "H5Tr"));
	unittest {
			assert(H5Tbody.row == "<tbody><tr></tr></tbody>");
	}}
}
mixin(H5Short!"Tbody");
unittest {
    assert(H5Tbody == "<tbody></tbody>");
}}
