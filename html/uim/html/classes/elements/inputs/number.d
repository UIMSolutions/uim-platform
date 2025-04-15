module uim.html.classes.elements.inputs.number;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputNUMBER : DH5Input {
	mixin(H5This!("Input", null, `["type":"number"]`, true)); 
}
mixin(H5Short!"InputNUMBER"); 

unittest {
		// TODO Add Test
		}}