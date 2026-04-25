/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.organization;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// An organization — the top-level grouping for spaces, users, and quotas
/// within a Cloud Foundry environment.
struct Organization {
  mixin TenantEntity!OrgId;

  string name;
  OrgStatus status = OrgStatus.active;
  int memoryQuotaMb = 10_240; // 10 GB default org quota
  int instanceMemoryLimitMb = 2048; // per-instance memory cap
  int totalRoutes = 1000;
  int totalServices = 100;
  int totalAppInstances = -1; // -1 = unlimited

}
