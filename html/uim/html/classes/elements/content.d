module uim.html.classes.elements.content;

import uim.html;
@safe:

class DH5Content : DH5Obj {
	mixin(H5This!("content"));
}
mixin(H5Short!"Content");

unittest {
  testH5Obj(H5Content, "content");
}}
