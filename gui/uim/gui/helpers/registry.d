/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.gui.helpers.registry;

import uim.gui;
mixin(Version!"test_uim_gui");

@safe:

class DGuiRegistry : DObjectRegistry!IGui {
    mixin(RegistryThis!"Gui");
}
mixin(RegistryCalls!"Gui");

unittest {
    auto registry = new DGuiRegistry();
    assert(registry !is null, "GuiRegistry is null!");

    assert(testGui(registry, "Gui"), "GuiRegistry test failed!");
}
