/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.application.usecases.manage.feature_flags;

import uim.platform.feature_flags;
import std.conv      : to, ConvException;
import std.algorithm : map;
import std.array     : array;
import core.time     : MonoTime;

// mixin(ShowModule!());

@safe:

class ManageFeatureFlagsUseCase {
    private FeatureFlagRepository repo;
    private AuditEntryRepository  audit;

    this(FeatureFlagRepository repo, AuditEntryRepository audit) {
        this.repo  = repo;
        this.audit = audit;
    }

    FeatureFlag getFlag(TenantId tenantId, FlagId id) {
        return repo.find(tenantId, id);
    }

    FeatureFlag getFlagByName(TenantId tenantId, ServiceInstanceId instanceId, string name) {
        return repo.findByName(tenantId, instanceId, name);
    }

    FeatureFlag[] listFlags(TenantId tenantId) {
        return repo.find(tenantId);
    }

    FeatureFlag[] listFlagsByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    FlagResult createFlag(CreateFeatureFlagRequest req) {
        if (req.name.length == 0)
            return FlagResult(false, "", "Flag name is required");
        if (req.instanceId.length == 0)
            return FlagResult(false, "", "Service instance ID is required");

        FlagType type_;
        try   { type_ = req.type_.to!FlagType; }
        catch (ConvException) { return FlagResult(false, "", "Invalid flag type: " ~ req.type_); }

        auto existing = repo.findByName(req.tenantId, ServiceInstanceId(req.instanceId), req.name);
        if (!existing.isNull)
            return FlagResult(false, "", "Flag with name '" ~ req.name ~ "' already exists in this instance");

        auto flag_ = FeatureFlag(req.tenantId);   // tenantId scoped via instanceId for simplicity
        flag_.id         = FlagId(generateId());
        flag_.name       = req.name;
        flag_.description = req.description;
        flag_.type_      = type_;
        flag_.state_     = FlagState.disabled_;
        flag_.instanceId = ServiceInstanceId(req.instanceId);
        flag_.defaultVariant = req.defaultVariant;
        flag_.labels     = req.labels;
        flag_.createdAt  = currentTimestamp();
        flag_.updatedAt  = flag_.createdAt;
        flag_.createdBy  = req.createdBy;

        flag_.variants = req.variants.map!(v => toVariant(v)).array;
        flag_.rules    = req.rules.map!((r) => toRule(r)).array;

        repo.save(flag_);
        appendAudit(flag_.tenantId, AuditAction.created_, "FeatureFlag", flag_.id.value, flag_.name, req.createdBy);
        return FlagResult(true, flag_.id.value, "");
    }

    FlagResult updateFlag(TenantId tenantId, FlagId id, UpdateFeatureFlagRequest req) {
        auto flag_ = repo.find(tenantId, id);
        if (flag_.isNull)
            return FlagResult(false, "", "Feature flag not found");

        if (req.description.length > 0) flag_.description = req.description;
        if (req.defaultVariant.length > 0) flag_.defaultVariant = req.defaultVariant;
        if (req.variants.length > 0) flag_.variants = req.variants.map!(v => toVariant(v)).array;
        if (req.rules.length > 0)    flag_.rules    = req.rules.map!((r) => toRule(r)).array;
        if (req.labels.length > 0)   flag_.labels   = req.labels;
        flag_.updatedAt = currentTimestamp();
        flag_.updatedBy = req.updatedBy;

        repo.update(flag_);
        appendAudit(tenantId, AuditAction.updated_, "FeatureFlag", id.value, flag_.name, req.updatedBy);
        return FlagResult(true, id.value, "");
    }

    FlagResult patchFlagState(TenantId tenantId, FlagId id, PatchFeatureFlagRequest req) {
        auto flag_ = repo.find(tenantId, id);
        if (flag_.isNull)
            return FlagResult(false, "", "Feature flag not found");

        FlagState newState;
        try   { newState = req.state_.to!FlagState; }
        catch (ConvException) { return FlagResult(false, "", "Invalid state: " ~ req.state_); }

        flag_.state_    = newState;
        flag_.updatedAt = currentTimestamp();
        flag_.updatedBy = req.updatedBy;

        repo.update(flag_);
        auto action_ = newState == FlagState.enabled_  ? AuditAction.enabled_
                     : newState == FlagState.archived_  ? AuditAction.archived_
                     : AuditAction.disabled_;
        appendAudit(tenantId, action_, "FeatureFlag", id.value, flag_.name, req.updatedBy);
        return FlagResult(true, id.value, "");
    }

    FlagResult deleteFlag(TenantId tenantId, FlagId id, string deletedBy = "") {
        auto flag_ = repo.find(tenantId, id);
        if (flag_.isNull)
            return FlagResult(false, "", "Feature flag not found");

        repo.remove(flag_);
        appendAudit(tenantId, AuditAction.deleted_, "FeatureFlag", id.value, flag_.name, deletedBy);
        return FlagResult(true, id.value, "");
    }

    private:

    FlagVariant toVariant(VariantDTO v) {
        FlagVariant fv;
        fv.id          = VariantId(generateId());
        fv.key         = v.key;
        fv.name        = v.name;
        fv.description = v.description;
        fv.value       = v.value;
        fv.weight      = v.weight;
        return fv;
    }

    TargetingRule toRule(TargetingRuleDTO r) {
        TargetingRule tr;
        tr.id          = RuleId(generateId());
        tr.name        = r.name;
        tr.description = r.description;
        tr.variantKey  = r.variantKey;
        tr.priority    = r.priority;
        tr.targetIds   = r.targetIds;
        tr.rolloutPercentage    = r.rolloutPercentage;
        tr.attributeConstraints = r.attributeConstraints;
        try   { tr.type_ = r.type_.to!RuleType; }
        catch (ConvException) { tr.type_ = RuleType.userMatch; }
        return tr;
    }

    void appendAudit(TenantId tenantId, AuditAction action_, string entityType,
                     string entityId, string entityName, string performedBy) {
        AuditEntry entry;
        entry.id          = AuditEntryId(generateId());
        entry.tenantId    = tenantId;
        entry.action_     = action_;
        entry.entityType  = entityType;
        entry.entityId    = entityId;
        entry.entityName  = entityName;
        entry.performedBy = performedBy;
        entry.performedAt = currentTimestamp();
        audit.append(entry);
    }

    string generateId() {
        import std.uuid : randomUUID;
        return randomUUID().toString();
    }

    string currentTimestamp() {
        import std.datetime : Clock, UTC;
        return Clock.currTime(UTC()).toISOExtString();
    }
}
