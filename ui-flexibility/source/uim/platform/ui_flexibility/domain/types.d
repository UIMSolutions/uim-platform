/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.types;

import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

// ─── Domain ID types ─────────────────────────────────────────────────────────

struct FlexChangeId {
  mixin IdTemplate;

  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexVariantId {
  mixin IdTemplate;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexVersionId {
  mixin IdTemplate;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexDraftId {
  mixin IdTemplate;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexPersonalizationId {
  mixin IdTemplate;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexApplicationId {
  mixin IdTemplate;
  this(string value) {
    this.value = value;
  }

  string value;
}
