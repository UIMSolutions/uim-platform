﻿module uim.html.classes.elements.body_;

import uim.html;
@safe:

class DH5Body : DH5Obj {
	mixin(H5This!("body"));

	O scripts(this O)(string[] links) { foreach(l; links) add(H5Script(["src":l])); return cast(O)this; }
	O script(this O, T...)(T values) { add(H5Script(values)); return cast(O)this; }
}
mixin(H5Short!"Body");

unittest {
	assert(H5Body);
	assert(H5Body == "<body></body>");
}}
