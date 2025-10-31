/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.range;

mixin(Version!"test_uim_html");

mixin(Version!"test_uim_html");

import uim.html;

@safe:

/**
 * @class DH5InputRANGE
 * @brief Input element of type range
 * 
 * This class represents an input element of type "range" in HTML5.
 * It is used to create a slider in forms.
 */
class DH5InputRANGE : DH5Input {
  mixin(H5This!("Input", null, `["type":"range"]`, true));
}

mixin(H5Short!"InputRANGE");

unittest {
  // TODO Add Test
}
