/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.summary;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <summary> HTML element is used as a summary, caption, or legend for the content of a <details> element. It provides a visible heading that users can click to expand or collapse the associated details content. The <summary> element is typically displayed in a bold font and may include additional styling to indicate its interactive nature. It enhances the user experience by allowing users to control the visibility of additional information, making it useful for FAQs, disclosures, and other expandable content sections.
class DH5Summary : DH5Obj {
	mixin(H5This!"summary");
}
mixin(H5Short!"Summary");

unittest {
    assert(H5Summary == "<summary></summary>");
}
