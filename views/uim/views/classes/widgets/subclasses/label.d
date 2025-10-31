/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.widgets.subclasses.label;

mixin(Version!("test_uim_views"));

import uim.views;
@safe:

// Form "widget" for creating labels.
class DLabelWidget : DWidget {
  mixin(WidgetThis!("Label"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _labelTemplate = "label";

    return true;
  }

  // The template to use.
  protected string _labelTemplate;

  /**
     * This class uses the following template:
     * - `label` Used to generate the label for a radio button.
     * Can use the following variables `attrs`, `text` and `input`.
     */
  this(DStringContents newTemplates) {
    // super(newTemplates);
  }

  // Render a label widget.
  override string render(Json[string] options, IFormContext formContext) {
    // set defaults
    options.merge("text", ""); // `text` The text for the label.
    options.merge("input", ""); // `input` The input that can be formatted into the label if the template allows it.
    options.merge("hidden", "");
    options.merge("escape", true); // `escape` Set to false to disable HTML escaping.
    options.merge("templateVars", Json.emptyArray());

    Json[string] settings = MapHelper.create!(string, Json);
    settings.set("text", options.getBoolean("escape") ? htmlAttributeEscape(
        options.getString("text")) : options.getString("text"));
    settings.set("input", options.get("input", Json(null)));
    settings.set("hidden", options.get("hidden", Json(null)));
    settings.set("templateVars", options.get("templateVars", Json(null)));
    /* .set("attrs", AttributeHelper.formatAttributes(options, [
                "text", "input", "hidden"
            ])) * /); */
    return _stringContents.format(_labelTemplate, settings);
  }
}

mixin(WidgetCalls!("Label"));

unittest {
  assert(LabelWidget);
}
