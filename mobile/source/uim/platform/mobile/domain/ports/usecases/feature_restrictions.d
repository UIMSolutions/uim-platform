/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.feature_restrictions;
// import uim.platform.mobile.domain.ports.repositories.feature_restrictions;
// import uim.platform.mobile.domain.entities.feature_restriction;

// import uim.platform.mobile.domain.services.feature_evaluation_service;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageFeatureRestrictionsUseCase { 
    
    UsecaseResult createFeatureRestriction(CreateFeatureRestrictionRequest r);

    UsecaseResult updateFeatureRestriction(UpdateFeatureRestrictionRequest r);

    bool evaluateRestriction(TenantId tenantId, FeatureRestrictionId featureId, UserId userId, string deviceId);

    FeatureRestriction getFeatureRestriction(TenantId tenantId, FeatureRestrictionId id);

    FeatureRestriction[] listFeatureRestrictions(TenantId tenantId);

    FeatureRestriction[] listFeatureRestrictions(TenantId tenantId, MobileAppId appId);

    UsecaseResult deleteFeatureRestriction(TenantId tenantId, FeatureRestrictionId id);

    size_t countFeatureRestrictions(TenantId tenantId, MobileAppId appId);

}
