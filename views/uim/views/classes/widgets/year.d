/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.widgets.year;

import uim.views;
@safe:

version (test_uim_views) {
  unittest {
    writeln("-----  ", __MODULE__, "\t  -----");
  }
} 


/**
 * Input widget class for generating a calendar year select box.
 *
 * This class is usually used internally by `UIM\View\Helper\FormHelper`,
 * it but can be used to generate standalone calendar year select boxes.
 */
class DYearWidget : DWidget {
    mixin(WidgetThis!("Year"));

    override bool initialize(Json[string] initData = null) {
        if (!super.initialize(initData)) {
            return false;
        }

        configuration
            .setEntry("name", "")
            .setEntry("val", Json(null))
            .setEntry("min", Json(null))
            .setEntry("max", Json(null))
            .setEntry("order", "desc")
            .setEntry("templateVars", Json.emptyArray);

        return true;
    }

    // Select box widget
    protected DSelectBoxWidget _select;

    this(DStringContents newTemplates, DSelectBoxWidget selectBox) {
        // super(newTemplates);
        _select = selectBox;
    }

    // Renders a year select box.
    override string render(Json[string] renderData, IFormContext formContext) {
        /* renderData.merge(formContext.data);


        if (renderData.hasKey("min")) {
            renderData.set("min", date("Y", strtotime("-5 years")));
        }
        if (renderData.hasKey("max")) {
            renderData.set("max", date("Y", strtotime("+5 years")));
        }
        renderData.set("min", renderData.getLong("min"));
        renderData.set("max", renderData.getLong("max"));

        if (
            cast(DChronosDate)mydata.get("val")  ||
            cast(DateTime)renderData.get("val")
       ) {
            renderData.set("val", mydata.get("val").format("Y"));
        }

        long minValue = mydata.getLong("min");
        long maxValue = mydata.getLong("max");
        if (renderData.isEmpty("val")) {
            renderData.set("min", min(mydata.getLong("val"), minValue));
            mydata.set("max", max(mydata.getLong("val"), maxValue));
        }
        minValue = mydata.getLong("min");
        maxValue = mydata.getLong("max");
        if (maxValue < minValue) {
            throw new DInvalidArgumentException("Max year cannot be less than min year");
        }

        mydata.set("options", mydata.getString("order") == "desc"
            ? range(maxValue, minValue)   
            : range(minValue, maxValue)
        );
            
        mydata.set("options", mydata["options"].combine(mydata["options"]));

        mydata.removeKey("order", "min", "max");
        return _select.render(mydata, formContext); */
        return null;
    }
}

mixin(WidgetCalls!("Year"));

unittest {
    assert(YearWidget);
}
