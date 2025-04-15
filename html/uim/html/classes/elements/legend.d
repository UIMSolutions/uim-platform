module uim.html.classes.elements.legend;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for <legend> - represents a caption for the content of its parent <fieldset>.
class DH5Legend : DH5Obj {
	mixin(H5This!"legend");
}
mixin(H5Short!"Legend");

unittest {
  testH5Obj(H5Legend, "legend");
}
