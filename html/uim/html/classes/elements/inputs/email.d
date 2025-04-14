module uim.html.classes.elements.inputs.email;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputEmail : DH5Input {
	mixin(H5This!("Input", null, `["type":"email"]`, true)); 
}
mixin(H5Short!"InputEmail");

unittest {
    assert(H5InputEmail == `<input type="email">`);
}