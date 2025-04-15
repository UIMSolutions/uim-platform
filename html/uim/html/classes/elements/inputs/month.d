/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.month;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/* TODO: Add support for the following attributes:
 * - min
 * - max
 * - value
 * - required
 * - disabled
 * - readonly
 * - placeholder
 * - pattern
 * - autocomplete
 * - autofocus
 * - list (for datalist)
 */
class DH5MonthInput : DH5Input {
  mixin(H5This!("Input", null, `["type":"month"]`, true));
}

mixin(H5Short!"InputMONTH");

unittest {
  // TODO Add Test
}
