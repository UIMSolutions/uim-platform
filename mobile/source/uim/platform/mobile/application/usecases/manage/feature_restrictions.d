/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.feature_restrictions;
// import uim.platform.mobile.domain.ports.repositories.feature_restrictions;
// import uim.platform.mobile.domain.entities.feature_restriction;

// import uim.platform.mobile.domain.services.feature_evaluation_service;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManageFeatureRestrictionsUseCase { // TODO: UIMUseCase {
    private FeatureRestrictionRepository repo;

    this(FeatureRestrictionRepository repo) {
        this.repo = repo;
    }

    CommandResult createFeatureRestriction(CreateFeatureRestrictionRequest r) {
        auto restriction = FeatureRestriction(r.tenantId);

        restriction.appId = r.appId;
        restriction.featureName = r.featureName;
        restriction.description = r.description;
        restriction.enabled = r.enabled;
        restriction.allowedUsers = r.allowedUsers;
        restriction.allowedDevices = r.allowedDevices;
        restriction.minAppVersion = r.minAppVersion;
        restriction.maxAppVersion = r.maxAppVersion;
        restriction.startDate = r.startDate;
        restriction.endDate = r.endDate;

        repo.save(restriction);
        return CommandResult(true, restriction.id.value, "");
    }

    CommandResult updateFeatureRestriction(UpdateFeatureRestrictionRequest r) {
        auto restriction = repo.find(r.tenantId, r.id);
        if (restriction.isNull)
            return CommandResult(false, "", "Feature restriction not found");
        if (r.description.length > 0) restriction.description = r.description;
        restriction.enabled = r.enabled;
        restriction.allowedUsers = r.allowedUsers;
        restriction.allowedDevices = r.allowedDevices;
        if (r.minAppVersion.length > 0) restriction.minAppVersion = r.minAppVersion;
        if (r.maxAppVersion.length > 0) restriction.maxAppVersion = r.maxAppVersion;
        restriction.startDate = r.startDate;
        restriction.endDate = r.endDate;
        restriction.updatedAt = currentTimestamp();
        restriction.updatedBy = r.updatedBy;
        repo.update(restriction);
        return CommandResult(true, restriction.id.value, "");
    }

    bool evaluateFeatureRestriction(TenantId tenantId, FeatureRestrictionId featureId, UserId userId, string deviceId) {
        auto restriction = repo.findById(tenantId, featureId);
        if (restriction.isNull)
            return false;
        return FeatureEvaluationService.evaluate(restriction, userId, deviceId);
    }

    FeatureRestriction getFeatureRestriction(TenantId tenantId, FeatureRestrictionId id) {
        return repo.findById(tenantId, id);
    }

    FeatureRestriction[] listFeatureRestrictions(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteFeatureRestriction(TenantId tenantId, FeatureRestrictionId id) {
        auto restriction = repo.findById(tenantId, id);
        if (restriction.isNull)
            return CommandResult(false, "", "Feature restriction not found");

        repo.remove(restriction);
        return CommandResult(true, restriction.id.value, "");
    }

    size_t countFeatureRestrictions(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
