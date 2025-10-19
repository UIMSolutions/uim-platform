/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.track;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <track> HTML element is used as a child of the <video> and <audio> elements to specify text tracks for media content. These text tracks can include subtitles, captions, descriptions, chapters, or metadata that enhance the accessibility and usability of the media for users. The <track> element allows web developers to provide multiple language options and additional information for their media content, improving the overall user experience.
class DH5Track : DH5Obj {
	mixin(H5This!"track");
	
	mixin(MyAttribute!("isDefault", "default"));
  mixin(MyAttribute!"label");
  mixin(MyAttribute!"src");
  mixin(MyAttribute!"srclang");
}
mixin(H5Short!"Track");

unittest {
  testH5Obj(H5Track, `track`);

	// mixin(testH5DoubleAttributes!("H5Track", "track", ["label", "src", "srclang"]));
}
