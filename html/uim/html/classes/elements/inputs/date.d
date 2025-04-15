module uim.html.classes.elements.inputs.date;

mixin(Version!("test_uim_html"));

import uim.html;

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
