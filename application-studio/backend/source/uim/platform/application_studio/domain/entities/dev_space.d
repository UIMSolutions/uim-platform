/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.dev_space;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A dev space: a developer's cloud workspace of a given type. Starting,
/// stopping, hibernation and deletion are completed by the reconciler.
struct DevSpace {
  mixin TenantEntity!DevSpaceId;

  string name; /// unique per tenant: letters, digits, "_" (max. 40)
  string description;
  DevSpaceTypeId devSpaceTypeId;
  string devSpaceTypeName;
  DevSpacePlan plan = DevSpacePlan.standard;
  DevSpaceStatus status = DevSpaceStatus.starting;
  string statusMessage;

  string owner; /// e-mail of the developer
  string region = "eu10";
  /// Additional extensions (names) on top of the type's predefined ones.
  string[] extensions;
  int hibernateAfterDays = 7; /// 0 = never
  int memoryLimitMb = 4096;
  int diskLimitGb = 10;

  string url; /// workspace URL, set when running
  long lastAccessedAt;
  long startedAt;
}
