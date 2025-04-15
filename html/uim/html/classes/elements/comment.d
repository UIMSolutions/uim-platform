module uim.html.classes.elements.comment;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Comment : DH5Obj {
	mixin(H5This!"comment");

	override string toString() {
//		auto content = "";
//		foreach(obj; objects) content ~= obj.toString;
//		return   "<!-- %s -->".format(content);
		return super.toString;
	}
}
mixin(H5Short!"Comment");

unittest {
  testH5Obj(H5Comment, "comment");
}}
