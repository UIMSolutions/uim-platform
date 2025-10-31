/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.menu;

import uim.html;
mixin(Version!("test_uim_html"));
@safe:

// The <menu> HTML element represents a group of commands that a user can perform or activate. It is typically used to create context menus, toolbars, or lists of options that are relevant to the current context or selection. The <menu> element can contain various interactive elements such as buttons, links, and other menu items, allowing users to easily access and execute commands within a web application or document.
class DH5Menu : DH5Obj {
	mixin(H5This!"menu");
}
mixin(H5Short!"Menu");

unittest {
  testH5Obj(H5Menu, "menu");
}
