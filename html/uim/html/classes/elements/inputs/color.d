module uim.html.classes.elements.inputs.color;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/**
 * @class DH5InputCOLOR
 * @brief Input element of type color
 * 
 * This class represents an input element of type "color" in HTML5.
 * It is used to create a color picker in forms.
 */
class DH5InputCOLOR : DH5Input {
	mixin(H5This!""); 

	override string toString() {
		this["TYPE"] = "color";
		return super.toString;
	}
}

unittest {
		// TODO Add Test
		}