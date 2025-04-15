/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.week;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

/**
 * @class DH5InputWEEK
 * @brief Input element of type week
 * 
 * This class represents an input element of type "week" in HTML5.
 * It is used to create a week picker in forms.
 */
class DH5InputWEEK : DH5Input {
  mixin(H5This!("Input", null, `["type":"week"]`, true));
}

mixin(H5Short!"InputWEEK");

unittest {
  // TODO: Add Test
}
