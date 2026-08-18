/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.ports.usecases.business_partners;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface IManageBusinessPartnersUseCase {

    BusinessPartner getPartner(TenantId tenantId, BusinessPartnerId id);
    BusinessPartner[] listPartners(TenantId tenantId);
    BusinessPartner[] listPartners(TenantId tenantId, BPCategory category);
    BusinessPartner[] listPartners(TenantId tenantId, BPStatus status);
    BusinessPartner[] listPartners(TenantId tenantId, string country);
    BusinessPartner[] searchPartners(TenantId tenantId, string searchTerm);
    UsecaseResult createPartner(BusinessPartnerDTO dto);
    UsecaseResult updatePartner(BusinessPartnerDTO dto);
    UsecaseResult deletePartner(TenantId tenantId, BusinessPartnerId id);

}
