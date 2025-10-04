/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.interfaces.h5obj;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

interface IH5Obj {
    IH5Obj removeClasses(string[] names...);
    IH5Obj removeClasses(string[] names);
    IH5Obj removeClass(string name);
}