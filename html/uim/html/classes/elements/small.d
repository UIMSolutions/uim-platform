/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.small;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <small> HTML element is used to represent side comments, disclaimers, or fine print text that is typically displayed in a smaller font size compared to the surrounding content. It is often used for legal disclaimers, copyright information, or other secondary text that is not the main focus of the document. The <small> element helps to visually differentiate this type of content from the primary text, making it easier for readers to identify and understand its purpose within the context of the webpage.
class DH5Small : DH5Obj {
	mixin(H5This!"small");
}
mixin(H5Short!"Small");

unittest {
    testH5Obj(H5Small, "small");
}

