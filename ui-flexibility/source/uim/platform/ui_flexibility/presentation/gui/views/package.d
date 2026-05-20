/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.gui.views;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Widget stub rendering a FlexChange detail panel (placeholder for real GUI toolkit).
class FlexChangeDetailView {
  private FlexChangeGuiModel model_;

  this(FlexChangeGuiModel model) {
    model_ = model;
    model_.addListener(&refresh);
  }

  void refresh() {
    // TODO: update GUI widgets from model_.value()
  }

  string render() const {
    auto c = model_.value();
    return "[FlexChange] ID=" ~ c.id_.value ~ " App=" ~ c.appId_ ~ " Type=" ~ c.changeType_.to!string;
  }
}

/// Widget stub rendering a FlexVariant list view.
class FlexVariantListView {
  private FlexVariantListGuiModel model_;

  this(FlexVariantListGuiModel model) {
    model_ = model;
    model_.addListener(&refresh);
  }

  void refresh() {
    // TODO: repopulate list widget from model_.values()
  }

  string[] render() const {
    string[] rows;
    foreach (v; model_.values())
      rows ~= "[FlexVariant] ID=" ~ v.id_.value ~ " Name=" ~ v.variantName_;
    return rows;
  }
}
