module uim.html.classes.elements.optgroup;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Optgroup : DH5Obj {
  mixin(H5This!"optgroup");

  //	O option(this O)() {
  //
  //	}
}

mixin(H5Short!"Optgroup");

unittest {
  assert(H5Optgroup == "<optgroup></optgroup>");
}
