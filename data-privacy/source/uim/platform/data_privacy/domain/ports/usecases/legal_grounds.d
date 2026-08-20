/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.legal_grounds;

// import uim.platform.data_privacy.domain.entities.legal_ground;
// import uim.platform.data_privacy.domain.ports.repositories.legal_grounds;
// import uim.platform.data_privacy.application.dto;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageLegalGroundsUseCase { 
  
  UsecaseResult createGround(CreateLegalGroundRequest req);
  LegalGround getGround(TenantId tenantId, LegalGroundId id);
  LegalGround[] listGrounds(TenantId tenantId);
  LegalGround[] listGrounds(TenantId tenantId, DataSubjectId subjectId);
  LegalGround[] listGrounds(TenantId tenantId, LegalBasis basis);
  LegalGround[] listGrounds(TenantId tenantId, ProcessingPurpose purpose);
  UsecaseResult updateGround(UpdateLegalGroundRequest req);
  UsecaseResult deleteGround(TenantId tenantId, LegalGroundId id);
  
}
