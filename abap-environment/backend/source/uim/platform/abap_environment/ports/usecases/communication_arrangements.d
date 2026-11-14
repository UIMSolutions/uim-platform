/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.ports.usecases.communication_arrangements;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Communication arrangements with credential and endpoint validation.
interface IManageCommunicationArrangementsUseCase : IManageResource!(CommunicationArrangement,
    CommunicationArrangementId, CreateCommunicationArrangementRequest, UpdateCommunicationArrangementRequest) {
  UsecaseResult activate(TenantId tenantId, CommunicationArrangementId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, CommunicationArrangementId id, UserId actor);
}
