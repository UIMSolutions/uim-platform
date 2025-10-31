/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.color;

import uim.html;
mixin(Version!("test_uim_html"));
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