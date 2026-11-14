/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.dev_space_type;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A dev space type: a preconfigured tool set ("SAP Fiori", "Full-Stack Cloud
/// Application", ...) — its predefined extensions are installed in every dev space of the type.
struct DevSpaceType {
  mixin TenantEntity!DevSpaceTypeId;

  string name; /// unique per tenant, e.g. "SAP Fiori"
  string description;
  DevSpaceTypeCategory category = DevSpaceTypeCategory.custom;
  string[] predefinedExtensions; /// extension names
  ProjectType[] supportedProjectTypes; /// empty = all
  string runtimeStack; /// e.g. "Node.js 20, Java 21"
  string iconUrl;
}
