/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the landscape: formations and system registrations.
module uim.platform.application_events.ports.usecases.landscape;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IManageFormations : IManageResource!(Formation, FormationId, FormationInput) {
  Formation activate(TenantId t, FormationId id, UserId actor);
  /// Stops the routing between the systems of the formation.
  Formation deactivate(TenantId t, FormationId id, UserId actor);
  /// Put a system into the formation (or move it from another one).
  SystemRegistration assignSystem(TenantId t, FormationId id, SystemRegistrationId system, UserId actor);
  /// Refused while subscriptions of the system exist.
  SystemRegistration unassignSystem(TenantId t, SystemRegistrationId system, UserId actor);
}

interface IManageSystems : IManageResource!(SystemRegistration, SystemRegistrationId, SystemInput) {
  SystemRegistration activate(TenantId t, SystemRegistrationId id, UserId actor);
  SystemRegistration deactivate(TenantId t, SystemRegistrationId id, UserId actor);
}
