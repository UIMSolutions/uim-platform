/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageBusinessPurposesUseCase { 
    
    CommandResult createBusinessPurpose(CreateBusinessPurposeRequest req);
    CommandResult updateBusinessPurpose(UpdateBusinessPurposeRequest req);
    CommandResult activateBusinessPurpose(TenantId tenantId, BusinessPurposeId id);
    CommandResult deactivateBusinessPurpose(TenantId tenantId, BusinessPurposeId id);
    bool hasBusinessPurpose(TenantId tenantId, BusinessPurposeId id);
    BusinessPurpose getBusinessPurpose(TenantId tenantId, BusinessPurposeId id);
    BusinessPurpose[] listBusinessPurposes(TenantId tenantId);
    BusinessPurpose[] listBusinessPurposes(TenantId tenantId, ApplicationGroupId groupId);
    CommandResult deleteBusinessPurpose(TenantId tenantId, BusinessPurposeId id);

}
