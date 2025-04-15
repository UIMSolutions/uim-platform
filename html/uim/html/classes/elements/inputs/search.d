module uim.html.classes.elements.inputs.search;

mixin(Version!"test_uim_html");

import uim.html;

@safe:

/**
 * @class DH5InputSEARCH
 * @brief Class for creating an HTML5 input element of type "search".
 * 
 * This class extends the DH5Input class and is used to create an input element
 * specifically designed for search functionality. It includes the necessary
 * attributes and properties to function as a search input.
 */
class DH5InputSEARCH : DH5Input {
  mixin(H5This!("Input", null, `["type":"search"]`, true));
}

mixin(H5Short!"InputSEARCH");

unittest {
  // TODO Add Test
}
