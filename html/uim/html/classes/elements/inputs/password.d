/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.password;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5InputPASSWORD : DH5Input {
  mixin(H5This!("Input", null, `["type":"password"]`, true));
}
