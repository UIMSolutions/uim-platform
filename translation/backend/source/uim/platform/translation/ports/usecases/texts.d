/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.usecases.texts;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Maintain the source texts of a project and their translations.
interface IManageProjectTextsUseCase : IManageResource!(ProjectText, ProjectTextId,
    CreateProjectTextRequest, UpdateProjectTextRequest) {
  /// Translate one text into every target language of its project (reviewed translations are kept).
  UsecaseResult translate(TenantId tenantId, ProjectTextId id, UserId actor);
  /// Set the translation of one language manually; marks it reviewed.
  UsecaseResult setTranslation(TenantId tenantId, ProjectTextId id, string language, string text, UserId actor);
  /// Confirm the translation of `language` ("" = every language).
  UsecaseResult review(TenantId tenantId, ProjectTextId id, string language, UserId actor);
  ProjectText[] byProject(TenantId tenantId, TranslationProjectId projectId);
}
