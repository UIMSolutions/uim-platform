module uim.html.classes.elements.cite;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

// Wrapper for cite tag - used to describe a reference to a cited creative work, and must include the title of that work. 
class DH5Cite : DH5Obj {
	mixin(H5This!"cite");
}
mixin(H5Short!"Cite");

unittest {
  assert(H5Cite);
  assert(H5Cite == "<cite></cite>");
}

