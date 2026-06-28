/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.manage.conditions;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

class ManageConditionsUseCase {
    private ConditionRepository repo;

    this(ConditionRepository repo) { this.repo = repo; }

    CommandResult createCondition(TenantId tenantId, CreateConditionRequest req) {
        if (repo.existsByName(tenantId, req.name))
            return CommandResult(false, "", "Condition '" ~ req.name ~ "' already exists");

        auto cond = Condition(tenantId);
        cond.name      = req.name;
        cond.description = req.description;
        cond.propertyKey  = req.propertyKey.to!PropertyKey;
        cond.predicate    = req.predicate.to!Predicate;
        cond.propertyValue = req.propertyValue;
        cond.mandatory    = req.mandatory;
        cond.labels       = req.labels.dup;

        repo.save(cond);
        return CommandResult(true, cond.id.toString(), cond.toJson().toString());
    }

    QueryResult getCondition(TenantId tenantId, string id) {
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return QueryResult(false, "Condition not found", Json.emptyObject);
        return QueryResult(true, "", cond.toJson());
    }

    QueryResult listConditions(TenantId tenantId) {
        auto items = repo.find(tenantId);
        auto arr   = Json.emptyArray;
        foreach (c; items) arr ~= c.toJson();
        return QueryResult(true, "", arr);
    }

    CommandResult updateCondition(TenantId tenantId, string id, UpdateConditionRequest req) {
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return CommandResult(false, "", "Condition not found");

        if (req.description.length)  cond.description  = req.description;
        if (req.propertyKey.length)  cond.propertyKey   = req.propertyKey.to!PropertyKey;
        if (req.predicate.length)    cond.predicate     = req.predicate.to!Predicate;
        if (req.propertyValue.length) cond.propertyValue = req.propertyValue;
        cond.mandatory = req.mandatory;
        if (req.labels.length) cond.labels = req.labels.dup;

        repo.save(cond);
        return CommandResult(true, cond.id.toString(), cond.toJson().toString());
    }

    CommandResult deleteCondition(TenantId tenantId, string id) {
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return CommandResult(false, "", "Condition not found");
        repo.removeById(tenantId, ConditionId(id));
        return CommandResult(true, id, "Condition deleted");
    }
}
