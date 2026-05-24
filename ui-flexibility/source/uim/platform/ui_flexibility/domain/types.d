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
  mixin DomainId;

  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexVariantId {
  mixin DomainId;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexVersionId {
  mixin DomainId;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexDraftId {
  mixin DomainId;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexPersonalizationId {
  mixin DomainId;
  this(string value) {
    this.value = value;
  }

  string value;
}

struct FlexApplicationId {
  mixin DomainId;
  this(string value) {
    this.value = value;
  }

  string value;
}
