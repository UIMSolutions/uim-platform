module uim.html.classes.elements.inputs.submit;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputSUBMIT : DH5Input {
	mixin(H5This!("Input", null, `["type":"submit"]`, true)); 
}
mixin(H5Short!"InputSUBMIT"); 

unittest {
		// TODO Add Test
		}}