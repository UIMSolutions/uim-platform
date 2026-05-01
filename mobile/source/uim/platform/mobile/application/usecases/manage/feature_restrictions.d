/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.feature_restrictions;

import uim.platform.mobile.domain.ports.repositories.feature_restrictions;
import uim.platform.mobile.domain.entities.feature_restriction;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.services.feature_evaluation_service;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageFeatureRestrictionsUseCase { // TODO: UIMUseCase {
    private FeatureRestrictionRepository repo;

    this(FeatureRestrictionRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateFeatureRestrictionRequest r) {
        FeatureRestriction restriction;
        restriction.id = randomUUID();
        restriction.tenantId = r.tenantId;
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
        restriction.createdAt = currentTimestamp();
        restriction.updatedAt = restriction.createdAt;
        restriction.createdBy = r.createdBy;
        repo.save(restriction);
        return CommandResult(true, restriction.id, "");
    }

    CommandResult update(FeatureRestrictionId id, UpdateFeatureRestrictionRequest r) {
        auto restriction = repo.findById(id);
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
        return CommandResult(true, restriction.id, "");
    }

    bool evaluate(FeatureRestrictionId featureId, string userId, string deviceId) {
        auto restriction = repo.findById(featureId);
        if (restriction.isNull)
            return false;
        return FeatureEvaluationService.evaluate(restriction, userId, deviceId);
    }

    FeatureRestriction get_(FeatureRestrictionId id) {
        return repo.findById(id);
    }

    FeatureRestriction[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    void remove(FeatureRestrictionId id) {
        repo.remove(id);
    }

    size_t countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
