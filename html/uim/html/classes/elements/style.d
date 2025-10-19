/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.style;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <style> HTML element is used to define internal CSS (Cascading Style Sheets) styles for a web document. It allows authors to embed CSS rules directly within the HTML file, enabling them to control the presentation and layout of the content on the page. The <style> element is typically placed within the <head> section of the HTML document and can contain various CSS properties and selectors to style elements such as fonts, colors, spacing, and more. By using the <style> element, developers can create visually appealing and consistent designs for their web pages.
class DH5Style : DH5Obj {
	mixin(H5This!("style"));
}
mixin(H5Short!"Style");
unittest {
    testH5Obj(H5Style, "style");
}

string toString(DH5Style[] someStyles) {
	return someStyles.map!(s => s.toString).join;
}
unittest {
    // assert([H5Style, H5Style].toString == "<style></style><style></style>");
}

DH5Style[] H5Styles(string[string][] someStyles...) { 
	return H5Styles(someStyles.dup); 
}

DH5Style[] H5Styles(string[string][] someStyles) { 
	return someStyles.map!(s => H5Style(s)).array;
}
