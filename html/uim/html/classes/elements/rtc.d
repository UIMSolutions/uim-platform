module uim.html.classes.elements.rtc;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Rtc : DH5Obj {
	mixin(H5This!"rtc");
}
mixin(H5Short!"Rtc");

version(test_uim_html) { unittest {
  testH5Obj(H5Rtc, "rtc");
}}
