/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.medication_requests;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageMedicationRequestsUseCase {

  CommandResult createMedicationRequest(CreateMedicationOrderRequest r);

  CommandResult updateMedicationRequest(UpdateMedicationOrderRequest r);

  MedicationRequest getMedicationRequest(TenantId tenantId, MedicationRequestId id);

  MedicationRequest[] listMedicationRequests(TenantId tenantId);

  MedicationRequest[] listByPatient(TenantId tenantId, string patientRef);

  CommandResult deleteMedicationRequest(TenantId tenantId, MedicationRequestId id);
  
}
