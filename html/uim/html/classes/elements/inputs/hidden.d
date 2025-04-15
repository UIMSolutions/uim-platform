module uim.html.classes.elements.inputs.hidden;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputHidden : DH5Input {
	mixin(H5This!("Input", null, `["type":"hidden"]`, true)); 
}
mixin(H5Short!"InputHidden"); 

unittest {
		// TODO Add Test
		}}