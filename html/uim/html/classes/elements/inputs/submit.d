/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.submit;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputSUBMIT : DH5Input {
  mixin(H5This!("Input", null, `["type":"submit"]`, true));
}

mixin(H5Short!"InputSUBMIT");

unittest {
  // TODO Add Test
}
