/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.web.views;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// Renders a minimal HTML page with a table of FlexChanges.
struct FlexChangesHtmlView {
  static string render(FlexChange[] changes) {
    import std.array : appender;
    auto buf = appender!string;
    buf ~= "<!DOCTYPE html><html><head><title>Flex Changes</title></head><body>";
    buf ~= "<table border='1'><tr><th>ID</th><th>AppId</th><th>Type</th><th>Layer</th><th>Active</th></tr>";
    foreach (c; changes) {
      buf ~= "<tr><td>" ~ c.id_.value ~ "</td><td>" ~ c.appId_ ~ "</td><td>"
           ~ c.changeType_.to!string ~ "</td><td>" ~ c.layer_.to!string ~ "</td><td>"
           ~ (c.isActive_ ? "Yes" : "No") ~ "</td></tr>";
    }
    buf ~= "</table></body></html>";
    return buf[];
  }
}

/// Renders a minimal HTML page with a table of FlexVariants.
struct FlexVariantsHtmlView {
  static string render(FlexVariant[] variants) {
    import std.array : appender;
    auto buf = appender!string;
    buf ~= "<!DOCTYPE html><html><head><title>Flex Variants</title></head><body>";
    buf ~= "<table border='1'><tr><th>ID</th><th>AppId</th><th>Name</th><th>Type</th><th>Default</th></tr>";
    foreach (v; variants) {
      buf ~= "<tr><td>" ~ v.id_.value ~ "</td><td>" ~ v.appId_ ~ "</td><td>"
           ~ v.variantName_ ~ "</td><td>" ~ v.variantType_.to!string ~ "</td><td>"
           ~ (v.isDefault_ ? "Yes" : "No") ~ "</td></tr>";
    }
    buf ~= "</table></body></html>";
    return buf[];
  }
}
