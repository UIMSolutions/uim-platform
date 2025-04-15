module uim.html.classes.elements.header;

import uim.html;
@safe:

class DH5Header : DH5Obj {
	mixin(H5This!("header"));
}
mixin(H5Short!"Header");

unittest {
  testH5Obj(H5Header, "header");
}}
