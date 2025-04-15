module uim.html.classes.elements.thead;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Thead : DH5Obj {
  mixin(H5This!"thead");

  mixin(MyContent!("tr", "H5Tr"));
  mixin(MyContent!("row", "H5Tr"));
}

mixin(H5Short!"Thead");

unittest {
  testH5Obj(H5Thead, "thead");
  assert(H5Thead.tr == "<thead><tr></tr></thead>");
  assert(H5Thead.row == "<thead><tr></tr></thead>");
}
