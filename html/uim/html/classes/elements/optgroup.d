/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.optgroup;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <optgroup> HTML element is used to group related options within a <select> dropdown list. It provides a way to organize options into categories, making it easier for users to navigate and select from a long list of choices. The <optgroup> element contains one or more <option> elements, and it can have a label attribute to specify the name of the group. This enhances the usability and accessibility of dropdown menus in web forms.
class DH5Optgroup : DH5Obj {
  mixin(H5This!"optgroup");

  //	O option(this O)() {
  //
  //	}
}

mixin(H5Short!"Optgroup");

unittest {
  testH5Obj(H5Optgroup, "optgroup");
}