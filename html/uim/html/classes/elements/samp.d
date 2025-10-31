/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.samp;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <samp> HTML element is used to represent sample output from a computer program or system. It is typically displayed in a monospaced font to distinguish it from regular text, making it easier to read and understand the output. The <samp> element is commonly used in documentation, tutorials, and technical articles to showcase examples of command-line output, error messages, or other program-generated text. By using the <samp> element, authors can clearly indicate that the enclosed text is intended to represent sample output, enhancing the clarity and usability of the content.
class DH5Samp : DH5Obj {
	mixin(H5This!"samp");
}
mixin(H5Short!"Samp");

unittest {
    assert(H5Samp,"<samp></samp>");
}
