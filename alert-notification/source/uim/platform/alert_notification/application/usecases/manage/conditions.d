/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.application.usecases.manage.conditions;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class ManageConditionsUseCase {
    private ConditionRepository repo;

    this(ConditionRepository repo) { this.repo = repo; }

    CommandResult createCondition(string tenantId, CreateConditionRequest req) {
        import std.conv : to;
        import std.uuid : randomUUID;

        auto existing = repo.findByName(tenantId, req.name);
        if (!existing.isNull())
            return CommandResult(false, "Condition '" ~ req.name ~ "' already exists");

        auto cond = new Condition();
        cond.id        = ConditionId(randomUUID().toString());
        cond.tenantId  = tenantId;
        cond.name      = req.name;
        cond.description = req.description;
        cond.propertyKey  = req.propertyKey.to!PropertyKey;
        cond.predicate    = req.predicate.to!Predicate;
        cond.propertyValue = req.propertyValue;
        cond.mandatory    = req.mandatory;
        cond.labels       = req.labels.dup;

        repo.save(cond);
        return CommandResult(true, cond.toJson().toString());
    }

    QueryResult getCondition(string tenantId, string id) {
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return QueryResult(false, "Condition not found", Json.emptyObject);
        return QueryResult(true, "", cond.toJson());
    }

    QueryResult listConditions(string tenantId) {
        auto items = repo.findAll(tenantId);
        auto arr   = Json.emptyArray;
        foreach (c; items) arr ~= c.toJson();
        return QueryResult(true, "", arr);
    }

    CommandResult updateCondition(string tenantId, string id, UpdateConditionRequest req) {
        import std.conv : to;
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return CommandResult(false, "Condition not found");

        if (req.description.length)  cond.description  = req.description;
        if (req.propertyKey.length)  cond.propertyKey   = req.propertyKey.to!PropertyKey;
        if (req.predicate.length)    cond.predicate     = req.predicate.to!Predicate;
        if (req.propertyValue.length) cond.propertyValue = req.propertyValue;
        cond.mandatory = req.mandatory;
        if (req.labels.length) cond.labels = req.labels.dup;

        repo.save(cond);
        return CommandResult(true, cond.toJson().toString());
    }

    CommandResult deleteCondition(string tenantId, string id) {
        auto cond = repo.findById(tenantId, ConditionId(id));
        if (cond is null || cond.isNull())
            return CommandResult(false, "Condition not found");
        repo.remove(tenantId, ConditionId(id));
        return CommandResult(true, "Condition deleted");
    }
}
