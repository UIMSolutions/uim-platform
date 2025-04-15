module uim.html.classes.elements.inputs.month;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputMONTH : DH5Input {
	mixin(H5This!("Input", null, `["type":"month"]`, true)); 
}
mixin(H5Short!"InputMONTH"); 

unittest {
		// TODO Add Test
		}