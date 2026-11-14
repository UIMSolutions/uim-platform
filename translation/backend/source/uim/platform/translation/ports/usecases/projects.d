/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.usecases.projects;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Maintain translation projects and translate all of their texts.
interface IManageProjectsUseCase : IManageResource!(TranslationProject, TranslationProjectId,
    CreateProjectRequest, UpdateProjectRequest) {
  /// draft → active (ready for translation).
  UsecaseResult activate(TenantId tenantId, TranslationProjectId id, UserId actor);
  /// Translate every text into every target language. Existing translations
  /// are kept unless `force` (reviewed translations are always kept).
  UsecaseResult translate(TenantId tenantId, TranslationProjectId id, bool force, UserId actor);
  /// Any status → archived (read-only).
  UsecaseResult archive(TenantId tenantId, TranslationProjectId id, UserId actor);
  /// archived → active.
  UsecaseResult reopen(TenantId tenantId, TranslationProjectId id, UserId actor);
  TranslationProject findByName(TenantId tenantId, string name);
}
