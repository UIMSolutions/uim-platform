module uim.html.classes.elements.rtc;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

class DH5Rtc : DH5Obj {
	mixin(H5This!"rtc");
}
mixin(H5Short!"Rtc");

unittest {
  testH5Obj(H5Rtc, "rtc");
}}
