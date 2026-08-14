/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.usecases.manage.medications;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface IManageMedicationsUseCase {

  CommandResult createMedication(CreateMedicationRequest r);

  CommandResult updateMedication(UpdateMedicationRequest r);

  Medication getMedication(TenantId tenantId, MedicationId id);

  Medication[] listMedications(TenantId tenantId);

  CommandResult deleteMedication(TenantId tenantId, MedicationId id);
  
}
