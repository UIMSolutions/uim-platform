module uim.html.classes.elements.col;

import uim.html;
@safe:

// The <col> HTML element defines a column within a table and is used to apply styles or attributes to entire columns, such as width or background color.
class DH5Col : DH5Obj {
	mixin(H5This!"col");

  mixin(MyAttribute!("span"));
  unittest {
    assert(H5Col.span("1") == `<col span="1"></col>`);
  }
}
mixin(H5Short!"Col");

unittest {
  testH5Obj(H5Col, "col");
}
