module uim.html.classes.elements.inputs.date;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputDate : DH5Input {
	mixin(H5This!("Input", null, `["type":"date"]`, true)); 
}
mixin(H5Short!"InputDate");

version(test_uim_html) { unittest {
    assert(H5InputDate == `<input type="date">`);
}}

