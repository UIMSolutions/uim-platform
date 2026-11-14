/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.project_text;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A source text of a translation project, identified by its text key, with
/// one translation per target language.
struct ProjectText {
  mixin TenantEntity!ProjectTextId;

  TranslationProjectId projectId;
  string projectName; /// denormalized for lists
  string name; /// text key, unique per project, e.g. "BUTTON_SAVE"
  string sourceText;
  TextType textType = TextType.uiText;
  int maxLength; /// 0 = unlimited
  string context; /// hint for translators
  TextTranslation[] translations;
  TextStatus status = TextStatus.untranslated;
}
