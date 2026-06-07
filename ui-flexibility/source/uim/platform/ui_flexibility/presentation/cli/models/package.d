/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.cli.models;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// CLI model wrapping a FlexChange for terminal display.
struct FlexChangeCliModel {
  FlexChange change;

  string summary() const {
    return change.id_.value ~ " | " ~ change.appId_ ~ " | " ~ change.changeType_.to!string;
  }
}

/// CLI model wrapping a FlexVariant for terminal display.
struct FlexVariantCliModel {
  FlexVariant variant;

  string summary() const {
    return variant.id_.value ~ " | " ~ variant.appId_ ~ " | " ~ variant.variantName_;
  }
}

/// CLI model wrapping a FlexVersion for terminal display.
struct FlexVersionCliModel {
  FlexVersion version_;

  string summary() const {
    return version_.id_.value ~ " | " ~ version_.appId_ ~ " | " ~ version_.status_.to!string;
  }
}

/// CLI model wrapping a FlexDraft for terminal display.
struct FlexDraftCliModel {
  FlexDraft draft;

  string summary() const {
    return draft.id_.value ~ " | " ~ draft.appId_;
  }
}
