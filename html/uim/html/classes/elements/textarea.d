/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.textarea;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

class DH5Textarea : DH5Obj {
  mixin(H5This!"textarea");

  O cols(this O)(uint value) {
    if (value > 0)
      this.attributes("cols", to!string(value));
    return cast(O)this;
  }

  O cols(this O)(string value) {
    if (value)
      this.attributes("cols", value);
    return cast(O)this;
  }

  unittest {
    assert(H5Textarea.cols(5) == `<textarea cols="5"></textarea>`);
    assert(H5Textarea.cols("5") == `<textarea cols="5"></textarea>`);
  }
}

O rows(this O)(uint value) {
  if (value > 0)
    this.attributes("rows", to!string(value));
  return cast(O)this;
}

O rows(this O)(string value) {
  if (value)
    this.attributes("rows", value);
  return cast(O)this;
}

unittest {
  assert(H5Textarea.rows(10) == `<textarea rows="10"></textarea>`);
  assert(H5Textarea.rows("10") == `<textarea rows="10"></textarea>`);
}

mixin(H5Short!"Textarea");

unittest {
  testH5Obj(H5Textarea, "textarea");
}
