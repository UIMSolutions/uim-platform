/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the ABAP environment aggregates.
/// (SubaccountId, ServiceBindingId and UserId come from uim-framework.)
module uim.platform.abap_environment.domain.types.ids;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A provisioned ABAP system (ABAP environment instance).
struct SystemInstanceId {
  mixin(IdTemplate);
}

/// A git-managed software component (gCTS repository) in a system.
struct SoftwareComponentId {
  mixin(IdTemplate);
}

/// A communication arrangement (scenario + communication system + user).
struct CommunicationArrangementId {
  mixin(IdTemplate);
}

/// A communication scenario (e.g. SAP_COM_0510).
struct CommunicationScenarioId {
  mixin(IdTemplate);
}

/// A CDS service definition exposed by a service binding.
struct ServiceDefinitionId {
  mixin(IdTemplate);
}

/// A business user of a system.
struct BusinessUserId {
  mixin(IdTemplate);
}

/// A business role of a system.
struct BusinessRoleId {
  mixin(IdTemplate);
}

/// A transport request (CTS).
struct TransportRequestId {
  mixin(IdTemplate);
}

/// An application job.
struct ApplicationJobId {
  mixin(IdTemplate);
}
