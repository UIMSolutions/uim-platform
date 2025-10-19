/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.video;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <video> HTML element is used to embed video content in a web page. It provides a standard way to display video files, allowing users to play, pause, and control the playback of the video directly within the browser. The <video> element supports various attributes to customize its behavior, such as autoplay, controls, loop, and preload. It can also include multiple source elements to provide different video formats for better compatibility across different browsers. Additionally, the <video> element can contain track elements for subtitles or captions, enhancing accessibility for users with hearing impairments.
class DH5Video : DH5Obj {
	mixin(H5This!"video");

	mixin(MyAttribute!"autoplay");
	mixin(MyAttribute!"buffered");
	mixin(MyAttribute!"controls");
	mixin(MyAttribute!"crossorigin");
	mixin(MyAttribute!"height");
	mixin(MyAttribute!"loop");
	mixin(MyAttribute!"muted");
	mixin(MyAttribute!"played");
	mixin(MyAttribute!"preload");
	mixin(MyAttribute!"poster");
	mixin(MyAttribute!"src");
	mixin(MyAttribute!"width");
	mixin(MyAttribute!"playsinline");	
	
	mixin(MyContent!("source", "H5Source"));
	mixin(MyContent!("track", "H5Track"));
}
mixin(H5Short!"Video");

unittest {
	testH5Obj(H5Video, "video");
	// mixin(testH5DoubleAttributes!("H5Video", "video", [	"autoplay", "buffered", "controls", "crossorigin", "height", "loop", "muted", "played", "preload", "poster", "src", "width", "playsinline"]));
}}
