/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.a;

mixin(Version!"test_uim_html");

import uim.html;
@safe:

// The <a> HTML element (or anchor element), with its href attribute, creates a hyperlink to web pages, files, email addresses, locations in the same page, or anything else a URL can address.
class DH5A : DH5Obj {
	mixin(H5This!"a");

	override bool initialize() {
		super.initialize;

		this
			.tag("a");	

		return true;	
	}

	// Attribute download - causes the browser to treat the linked URL as a download
	mixin(MyAttribute!"download");

	// Attribute href - The URL that the hyperlink points to
	mixin(MyAttribute!"href");

	// Attribute hreflang - Hints at the human language of the linked URL
	mixin(MyAttribute!"hreflang");

	// Attribute ping - A space-separated list of URLs. 
	// When the link is followed, the browser will send POST requests with the body PING to the URLs. Typically for tracking.
	mixin(MyAttribute!"ping");

	// Attribute reffererpolicy - How much of the referrer to send when following the link.
	// Valid values: no-referrer, no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
	mixin(MyAttribute!"referrerpolicy");

	// Attribute rel - The relationship of the linked URL as space-separated link types.
	mixin(MyAttribute!"rel");

	// Attribute target - Where to display the linked URL, as the name for a browsing context (a tab, window, or <iframe>)
	// Valid values: _self, _blank, _parent, _top 
	mixin(MyAttribute!"target");

	// Attribute type - Hints at the linked URL's format with a MIME type.
	mixin(MyAttribute!"type");
}
mixin(H5Short!"A");

unittest {
	testH5Obj(H5A, "a");
  assert(H5A == `<a></a>`);
  
	mixin(TestH5DoubleAttributes!("H5A", "a", [
		"download", "href", "hreflang", "ping", "referrerpolicy", "rel", "target", "type"
	]));
}

