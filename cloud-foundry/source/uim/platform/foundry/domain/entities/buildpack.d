/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.buildpack;

import uim.platform.foundry.domain.types;

/// A buildpack — provides the runtime detection, compilation, and start
/// scripts for staging applications (e.g. Java, Node.js, Go, Python).
struct Buildpack {
  BuildpackId id;
  TenantId tenantId;
  string name; // e.g. "java_buildpack", "nodejs_buildpack"
  BuildpackType type_ = BuildpackType.system;
  int position = 0; // detection order priority
  string stack = "cflinuxfs4";
  string filename; // archive filename for custom buildpacks
  bool enabled = true;
  bool locked = false;
  string createdBy;
  long createdAt;
  long updatedAt;
}
