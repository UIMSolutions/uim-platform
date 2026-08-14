/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.patients;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManagePatientsUseCase {

  CommandResult createPatient(CreatePatientRequest r);

  CommandResult updatePatient(UpdatePatientRequest r);
  
  Patient getPatient(TenantId tenantId, PatientId id);

  Patient[] listPatients(TenantId tenantId);

  Patient[] searchByName(TenantId tenantId, string namePart);

  CommandResult deletePatient(TenantId tenantId, PatientId id);

  size_t countPatients(TenantId tenantId);
  
}
