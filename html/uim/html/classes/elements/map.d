module uim.html.classes.elements.map;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

class DH5Map : DH5Obj {
	mixin(H5This!("map"));
}
mixin(H5Short!"Map");

version(test_uim_html) { unittest {
    testH5Obj(H5Map, "map");
}}
