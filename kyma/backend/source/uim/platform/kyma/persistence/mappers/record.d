/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.mappers.record;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Generic mapper between entities and database records, driven by
/// compile-time reflection (see helpers.codec). Records keep timestamps as raw
/// std-time numbers and enums by name; unknown or missing fields fall back to
/// the entity defaults, so older snapshots stay readable.
struct RecordMapper(TEntity) {
  static Json toRecord(const TEntity entity) {
    return encode(entity, false);
  }

  static TEntity fromRecord(Json record) {
    return decode!TEntity(record);
  }
}

alias EnvironmentMapper = RecordMapper!KymaEnvironment;
alias NamespaceMapper = RecordMapper!KymaNamespace;
alias FunctionMapper = RecordMapper!ServerlessFunction;
alias ApiRuleMapper = RecordMapper!ApiRule;
alias ServiceInstanceMapper = RecordMapper!ServiceInstance;
alias ServiceBindingMapper = RecordMapper!ServiceBinding;
alias EventSubscriptionMapper = RecordMapper!EventSubscription;
alias ModuleMapper = RecordMapper!KymaModule;
alias ApplicationMapper = RecordMapper!KymaApplication;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto rule = ApiRule(TenantId("t1"));
  rule.name = "orders";
  rule.rules = [ApiRuleEntry("/orders", [ApiHttpMethod.get_, ApiHttpMethod.post_], AccessStrategy.jwt,
      ["read"], null, ["https://idp.example.com"])];
  auto record = ApiRuleMapper.toRecord(rule);
  assert(record["rules"][0]["methods"][1].get!string == "POST");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(ApiRuleMapper.fromRecord(record) == rule);
}
