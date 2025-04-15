module uim.html.classes.elements.inputs.password;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputPASSWORD : DH5Input {
	mixin(H5This!("Input", null, `["type":"password"]`, true)); 
}
mixin(H5Short!"InputPASSWORD"); 

unittest {
		// TODO Add Test
		}}