/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim-platform.views.uim.views.classes.widgets.subclasses.nestinglabel;

mixin(Version!("test_uim_views"));

import uim.views;
@safe:

/* * Form "widget" for creating labels that contain their input.
 *
 * Generally this element is used by other widgets,
 * and FormHelper it
 */
class DNestingLabelWidget : DLabelWidget {
    mixin(WidgetThis!("NestingLabel"));

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        return true;
    }

    // The template to use.
    protected string _labelTemplate = "nestingLabel";
}
mixin(WidgetCalls!("NestingLabel"));

unittest {
    assert(NestingLabelWidget);
}