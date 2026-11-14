/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.usecases.catalog;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Dev space types: predefined ones are protected; types in use cannot be deleted.
interface IManageDevSpaceTypesUseCase : IManageResource!(DevSpaceType, DevSpaceTypeId,
    CreateDevSpaceTypeRequest, UpdateDevSpaceTypeRequest) {
}

/// Extensions of the catalogue.
interface IManageExtensionsUseCase : IManageResource!(Extension, ExtensionId,
    CreateExtensionRequest, UpdateExtensionRequest) {
  UsecaseResult activate(TenantId tenantId, ExtensionId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, ExtensionId id, UserId actor);
  UsecaseResult deprecate(TenantId tenantId, ExtensionId id, UserId actor);
}

/// Project templates (generators).
interface IManageProjectTemplatesUseCase : IManageResource!(ProjectTemplate, ProjectTemplateId,
    CreateProjectTemplateRequest, UpdateProjectTemplateRequest) {
}
