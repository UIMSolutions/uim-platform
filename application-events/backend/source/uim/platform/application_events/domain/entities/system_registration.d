/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A registered SAP cloud system (S/4HANA Cloud, SuccessFactors, a BTP
/// application, …) that produces and / or consumes events. Its id is the
/// CloudEvents "source" of the events it publishes.
module uim.platform.application_events.domain.entities.system_registration;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct SystemRegistration {
  mixin TenantEntity!SystemRegistrationId;

  string name;
  string description;
  SystemType systemType = SystemType.both;
  string systemUrl; /// base URL (informational)
  FormationId formationId; /// "" = not assigned
  SystemStatus status = SystemStatus.active;

  bool isActive() const {
    return status == SystemStatus.active;
  }

  bool produces() const {
    return canProduce(systemType);
  }

  bool consumes() const {
    return canConsume(systemType);
  }

  void validate() const {
    requireId(id.value, "System ID");
    requireText(name, "System name");
    requireMaxLength(name, 200, "System name");
    requireMaxLength(description, 2000, "Description");
    requireHttpUrl(systemUrl, "System URL");
  }
}

///
unittest {
  SystemRegistration s;
  s.id = SystemRegistrationId("s4");
  s.name = "S/4HANA Cloud";
  s.systemType = SystemType.producer;
  s.validate();
  assert(s.produces && !s.consumes && s.isActive);
  s.systemUrl = "not a url";
  assert(failsWith(AehErrorKind.invalid, () { s.validate(); }));
}
