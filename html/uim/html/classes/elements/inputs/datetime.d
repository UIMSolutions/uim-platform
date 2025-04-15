module uim.html.classes.elements.inputs.datetime;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

class DH5InputDATETIME : DH5Input {
  mixin(H5This!("Input", null, `["type":"datetime"]`, false));
}

unittest {
  // TODO Add Test
}
