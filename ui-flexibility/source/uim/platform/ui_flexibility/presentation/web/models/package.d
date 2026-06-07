/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.web.models;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// Web-layer model adapter for FlexChange — exposes HTML-friendly properties.
struct FlexChangeWebModel {
  FlexChange change;

  string cssClass() const {
    return change.isActive_ ? "change-active" : "change-inactive";
  }

  string displayLabel() const {
    return change.changeType_.to!string ~ ": " ~ change.appId_;
  }
}

/// Web-layer model adapter for FlexVariant.
struct FlexVariantWebModel {
  FlexVariant variant;

  string cssClass() const {
    return variant.isDefault_ ? "variant-default" : "variant-custom";
  }

  string displayLabel() const {
    return variant.variantName_ ~ " (" ~ variant.variantType_.to!string ~ ")";
  }
}
