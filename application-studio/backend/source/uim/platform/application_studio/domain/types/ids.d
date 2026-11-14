/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the Application Studio aggregates.
/// (TenantId, UserId and ServiceBindingId come from uim-framework.)
module uim.platform.application_studio.domain.types.ids;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A dev space type (e.g. "SAP Fiori", "Full-Stack Cloud Application").
struct DevSpaceTypeId {
  mixin(IdTemplate);
}

/// An extension (VS Code compatible tool package) in the catalogue.
struct ExtensionId {
  mixin(IdTemplate);
}

/// A project template (generator).
struct ProjectTemplateId {
  mixin(IdTemplate);
}

/// A dev space (a developer's cloud workspace).
struct DevSpaceId {
  mixin(IdTemplate);
}

/// A project inside a dev space.
struct ProjectId {
  mixin(IdTemplate);
}

/// A run / debug / preview launch configuration of a project.
struct RunConfigurationId {
  mixin(IdTemplate);
}

/// A build-and-deploy configuration of a project.
struct BuildConfigurationId {
  mixin(IdTemplate);
}
