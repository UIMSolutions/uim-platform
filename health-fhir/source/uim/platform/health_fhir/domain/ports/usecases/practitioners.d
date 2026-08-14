/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.practitioners;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManagePractitionersUseCase {

  CommandResult createPractitioner(CreatePractitionerRequest r);

  CommandResult updatePractitioner(UpdatePractitionerRequest r);

  Practitioner getPractitioner(TenantId tenantId, PractitionerId id);

  Practitioner[] listPractitioners(TenantId tenantId);

  CommandResult deletePractitioner(TenantId tenantId, PractitionerId id);

  size_t countPractitioners(TenantId tenantId);
  
}
