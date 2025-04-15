﻿/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.inputs.image;

import uim.html;
@safe:

/* Add Image Input Class
 * <input type="image" src="img.jpg" alt="Submit" /> 
 * The image input type is used to create a graphical submit button. 
 * The image is specified in the src attribute. 
 * The alt attribute specifies an alternate text for the image, if the image for some reason cannot be displayed.
 */
class DH5InputIMAGE : DH5Input {
	mixin(H5This!("Input", null, `["type":"image"]`, true)); 
}
mixin(H5Short!"InputIMAGE"); 

unittest {
		// TODO Add Test
}