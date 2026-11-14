/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the translation aggregates.
/// (TenantId and UserId come from uim-framework.)
module uim.platform.translation.domain.types.ids;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A software translation project.
struct TranslationProjectId {
  mixin(IdTemplate);
}

/// A source text (text key) of a translation project.
struct ProjectTextId {
  mixin(IdTemplate);
}

/// An entry of the company glossary (company MLTR).
struct GlossaryEntryId {
  mixin(IdTemplate);
}

/// An asynchronous translation job.
struct TranslationJobId {
  mixin(IdTemplate);
}
