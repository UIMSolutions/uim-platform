/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.label;

import uim.html;

mixin(Version!("test_uim_html"));
@safe:

// The <label> HTML element represents a caption for an item in a user interface.
class DH5Label : DH5Obj {
  mixin(H5This!"label");

  mixin(MyAttribute!("forId", "for"));
  unittest {
    assert(H5Label.forId("anID") == `<label for="anID"></label>`);
    assert(H5Label.forId("anID").content("text") == `<label for="anID">text</label>`);
  }

  mixin(MyAttribute!("form"));
  unittest {
    assert(H5Label.form("aForm") == `<label form="aForm"></label>`);
    assert(H5Label.form("aForm").content("text") == `<label form="aForm">text</label>`);
  }
}

mixin(H5Short!"Label");

unittest {
  testH5Obj(H5Label, `label`);
}
