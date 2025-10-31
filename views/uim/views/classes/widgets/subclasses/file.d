/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.widgets.subclasses.file;

mixin(Version!("test_uim_views"));

import uim.views;
@safe:

/**
 * Input widget class for generating a file upload control.
 *
 * This class is usually used internally by `UIM\View\Helper\FormHelper`,
 * it but can be used to generate standalone file upload controls.
 */
class DFileWidget : DWidget {
    mixin(WidgetThis!("File"));

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        configuration
            .setEntry("name", "") // `name` - Set the input name.
            .setEntry("escape", true) // `escape` - Set to false to disable HTML escaping.
            .setEntry("templateVars", Json.emptyArray);

        return true;
    }

    /**
     * Render a file upload form widget.
     *
     * Data supports the following keys:
     *
     * All other keys will be converted into HTML attributes.
     * Unlike other input objects the `val` property will be specifically
     * ignored.
     */
    override string render(Json[string] renderData, IFormContext formContext) {
        /* renderData.merge(formContext.data);
        renderData.removeKey("val"); */

        /* return _stringContents.format("file", 
            renderData.data(["name", "templateVars"])
                .setPath(["attrs": AttributeHelper.formatAttributes(renderData, ["name"])]);  */
        return null; 
    }
}
mixin(WidgetCalls!("File"));

unittest {
    assert(FileWidget);
}