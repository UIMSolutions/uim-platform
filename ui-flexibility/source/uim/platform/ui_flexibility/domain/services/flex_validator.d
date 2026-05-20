/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.services.flex_validator;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Domain validation service for UI Flexibility entities.
struct FlexValidator {

  static string validateFlexChange(ref const FlexChange c) {
    if (c.appId_.length == 0)
      return "FlexChange: appId is required";
    if (c.selector_.length == 0)
      return "FlexChange: selector is required";
    if (c.content_.length == 0)
      return "FlexChange: content is required";
    return null;
  }

  static string validateFlexVariant(ref const FlexVariant v) {
    if (v.appId_.length == 0)
      return "FlexVariant: appId is required";
    if (v.variantName_.length == 0)
      return "FlexVariant: variantName is required";
    if (v.content_.length == 0)
      return "FlexVariant: content is required";
    return null;
  }

  static string validateFlexVersion(ref const FlexVersion v) {
    if (v.appId_.length == 0)
      return "FlexVersion: appId is required";
    if (v.displayName_.length == 0)
      return "FlexVersion: displayName is required";
    return null;
  }

  static string validateFlexDraft(ref const FlexDraft d) {
    if (d.appId_.length == 0)
      return "FlexDraft: appId is required";
    return null;
  }

  static string validateFlexPersonalization(ref const FlexPersonalization p) {
    if (p.appId_.length == 0)
      return "FlexPersonalization: appId is required";
    if (p.userId_.length == 0)
      return "FlexPersonalization: userId is required";
    if (p.controlId_.length == 0)
      return "FlexPersonalization: controlId is required";
    if (p.content_.length == 0)
      return "FlexPersonalization: content is required";
    return null;
  }

  static string validateFlexApplication(ref const FlexApplication a) {
    if (a.namespace_.length == 0)
      return "FlexApplication: namespace is required";
    if (a.appId_.length == 0)
      return "FlexApplication: appId is required";
    return null;
  }
}
