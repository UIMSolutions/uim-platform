/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.encounters;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageEncountersUseCase {

  CommandResult createEncounter(CreateEncounterRequest r);

  CommandResult updateEncounter(UpdateEncounterRequest r);

  Encounter getEncounter(TenantId tenantId, EncounterId id);

  Encounter[] listEncounters(TenantId tenantId);

  Encounter[] listByPatient(TenantId tenantId, string patientRef);

  CommandResult deleteEncounter(TenantId tenantId, EncounterId id);
  
}
