/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.span;

import uim.html;
mixin(Version!("test_uim_html")); 
@safe:

// The <span> HTML element is a generic inline container used to group and style inline elements within a document. It does not inherently represent anything specific but serves as a hook for applying CSS styles or JavaScript functionality to a portion of text or other inline content. The <span> element is commonly used for styling purposes, such as changing the color, font, or background of specific text segments, without affecting the overall structure of the document. It is a versatile and widely used element in web development for enhancing the presentation of content.
class DH5Span : DH5Obj {
	mixin(H5This!"Span");
}
mixin(H5Short!"Span");

unittest {	
	assert(H5Span == "<span></span>");
}
