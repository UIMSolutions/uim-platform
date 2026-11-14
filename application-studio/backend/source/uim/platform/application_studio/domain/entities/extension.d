/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.extension;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// An extension of the catalogue (VS Code compatible tool package).
struct Extension {
  mixin TenantEntity!ExtensionId;

  string name; /// unique per tenant, "publisher.package", e.g. "sap.fiori-tools"
  string displayName;
  string description;
  ExtensionScope scope_ = ExtensionScope.additional; /// "scope"
  ExtensionStatus status = ExtensionStatus.active;
  string version_ = "1.0.0"; /// "version", semantic version
  string publisher;
  string category;
  string[] dependencies; /// extension names that must be installed as well
  string[] capabilities;
  string iconUrl;
}
