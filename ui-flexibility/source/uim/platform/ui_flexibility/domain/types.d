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
    mixin(IdTemplate);

}

struct FlexVariantId {
  mixin(IdTemplate);
}

struct FlexVersionId {
  mixin(IdTemplate);
}

struct FlexDraftId {
  mixin(IdTemplate);
}

struct FlexPersonalizationId {
  mixin(IdTemplate);
}

struct FlexApplicationId {
  mixin(IdTemplate);
}
