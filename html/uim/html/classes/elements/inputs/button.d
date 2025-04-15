module uim.html.classes.elements.inputs.button;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5InputButton : DH5Input {
	mixin(H5This!("Input", null, `["type": "button"]`)); 
}
mixin(H5Short!"InputButton");

unittest {
	assert(H5InputButton);		
}}