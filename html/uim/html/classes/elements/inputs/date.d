/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.date;

import uim.html;
mixin(Version!("test_uim_html"));

@safe:

/**
 * @class DH5InputDate
 * @brief Input element of type date
 * 
 * This class represents an input element of type "date" in HTML5.
 * It is used to create a date picker in forms.
 */
class DH5InputDate : DH5Input {
  mixin(H5This!("Input", null, `["type":"date"]`, true));
}

mixin(H5Short!"InputDate");

unittest {
  assert(H5InputDate == `<input type="date">`);
}
