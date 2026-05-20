/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.gui.models;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Observable GUI model for FlexChange — notifies listeners on change.
class FlexChangeGuiModel {
  private FlexChange change_;
  private void delegate() @safe[] listeners_;

  this(FlexChange c) {
    change_ = c;
  }

  FlexChange value() const { return change_; }

  void setValue(FlexChange c) {
    change_ = c;
    foreach (l; listeners_) l();
  }

  void addListener(void delegate() @safe listener) {
    listeners_ ~= listener;
  }
}

/// Observable GUI model for a list of FlexVariants.
class FlexVariantListGuiModel {
  private FlexVariant[] variants_;
  private void delegate() @safe[] listeners_;

  FlexVariant[] values() const { return cast(FlexVariant[]) variants_; }

  void setValues(FlexVariant[] vs) {
    variants_ = vs;
    foreach (l; listeners_) l();
  }

  void addListener(void delegate() @safe listener) {
    listeners_ ~= listener;
  }
}
