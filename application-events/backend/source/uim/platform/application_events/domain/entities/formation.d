/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A formation: the systems of one customer landscape (e.g. an S/4HANA
/// Cloud tenant, SuccessFactors and side-by-side extensions on SAP BTP)
/// that may exchange events. Subscriptions connect systems of the same
/// formation only.
module uim.platform.application_events.domain.entities.formation;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct Formation {
  mixin TenantEntity!FormationId;

  string name;
  string description;
  string globalAccountId; /// SAP BTP global account (informational)
  FormationStatus status = FormationStatus.active;

  bool isActive() const {
    return status == FormationStatus.active;
  }

  void validate() const {
    requireId(id.value, "Formation ID");
    requireText(name, "Formation name");
    requireMaxLength(name, 200, "Formation name");
    requireMaxLength(description, 2000, "Description");
    requireMaxLength(globalAccountId, 200, "Global account");
  }
}

///
unittest {
  Formation f;
  f.id = FormationId("landscape");
  f.name = "Landscape";
  f.validate();
  assert(f.isActive);
  f.name = " ";
  assert(failsWith(AehErrorKind.invalid, () { f.validate(); }));
}
