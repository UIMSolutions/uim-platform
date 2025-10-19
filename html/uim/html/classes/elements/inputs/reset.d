/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.reset;

mixin(Version!"test_uim_html");

mixin(Version!"test_uim_html");

import uim.html;
@safe:

/**
 * @class DH5InputRESET
 * @brief Represents an HTML input element of type "reset".
 * 
 * This class is a specialization of the DH5Input class, specifically for creating
 * reset buttons in HTML forms. It inherits from DH5Input and uses the mixin
 * functionality to set the type attribute to "reset".
 */
class DH5InputRESET : DH5Input {
  mixin(H5This!("Input", null, `["type":"reset"]`, true));
}

mixin(H5Short!"InputRESET");

unittest {
  // TODO Add Test
}
