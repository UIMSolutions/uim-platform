/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.observations;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageObservationsUseCase {

  UsecaseResult createObservation(CreateObservationRequest r);

  UsecaseResult updateObservation(UpdateObservationRequest r);

  Observation getObservation(TenantId tenantId, ObservationId id);

  Observation[] listObservations(TenantId tenantId);

  Observation[] listByPatient(TenantId tenantId, string patientRef);

  UsecaseResult deleteObservation(TenantId tenantId, ObservationId id);
  
}
