module uim.html.classes.elements.inputs.time;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

/**
 * @class DH5InputTIME
 * @brief Input element of type time
 * 
 * This class represents an input element of type "time" in HTML5.
 * It is used to create a time picker in forms.
 */
class DH5InputTIME : DH5Input {
  mixin(H5This!("Input", null, `["type":"time"]`, true));
}

mixin(H5Short!"InputTIME");

unittest {
  // TODO Add Test
}
