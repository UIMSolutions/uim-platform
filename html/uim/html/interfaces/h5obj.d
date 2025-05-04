module uim.html.interfaces.h5obj;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

interface IH5Obj {
    IH5Obj removeClasses(string[] names...);
    IH5Obj removeClasses(string[] names);
    IH5Obj removeClass(string name);
}