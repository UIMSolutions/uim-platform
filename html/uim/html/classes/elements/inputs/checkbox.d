/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.checkbox;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Checkbox : DH5Input {
  mixin(H5This!("Input", null, `["type":"checkbox"]`));
}

mixin(H5Short!"Checkbox");

unittest {
  // TODO Add Test
}
