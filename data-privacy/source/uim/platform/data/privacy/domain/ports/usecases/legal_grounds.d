/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.legal_grounds;

// import uim.platform.data.privacy.domain.entities.legal_ground;
// import uim.platform.data.privacy.domain.ports.repositories.legal_grounds;
// import uim.platform.data.privacy.application.dto;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageLegalGroundsUseCase { 
  
  CommandResult createGround(CreateLegalGroundRequest req);
  LegalGround getGround(TenantId tenantId, LegalGroundId id);
  LegalGround[] listGrounds(TenantId tenantId);
  LegalGround[] listGrounds(TenantId tenantId, DataSubjectId subjectId);
  LegalGround[] listGrounds(TenantId tenantId, LegalBasis basis);
  LegalGround[] listGrounds(TenantId tenantId, ProcessingPurpose purpose);
  CommandResult updateGround(UpdateLegalGroundRequest req);
  CommandResult deleteGround(TenantId tenantId, LegalGroundId id);
  
}
