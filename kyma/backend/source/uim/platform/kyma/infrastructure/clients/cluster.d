/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.clients.cluster;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Cluster gateway that records what would be applied to the Kubernetes API.
/// Replace with a kube-apiserver client (service account token of the runtime)
/// to manage real clusters.
class RecordingClusterGateway : IClusterGateway {
  struct Operation {
    string environmentId;
    string verb; /// "apply" or "delete"
    string kind;
    string namespace_;
    string name;
  }

  protected Operation[] _operations;
  protected size_t _capacity;

  this(size_t capacity = 500) {
    _capacity = capacity;
  }

  void apply(KymaEnvironmentId environmentId, Json manifest) {
    auto meta = member(manifest, "metadata");
    record(Operation(environmentId.value, "apply", fieldString(manifest, "kind"),
        fieldString(meta, "namespace"), fieldString(meta, "name")));
    logDebug("kyma cluster %s: apply %s", environmentId.value, manifest.toString);
  }

  void remove(KymaEnvironmentId environmentId, string kind, string namespace_, string name) {
    record(Operation(environmentId.value, "delete", kind, namespace_, name));
    logDebug("kyma cluster %s: delete %s %s/%s", environmentId.value, kind, namespace_, name);
  }

  /// The most recent operations (oldest first).
  const(Operation)[] operations() const {
    return _operations;
  }

  protected void record(Operation op) {
    _operations ~= op;
    if (_operations.length > _capacity)
      _operations = _operations[$ - _capacity .. $];
  }
}

///
unittest {
  auto gw = new RecordingClusterGateway(2);
  auto m = parseJsonString(`{"kind": "Function", "metadata": {"name": "f", "namespace": "shop"}}`);
  gw.apply(KymaEnvironmentId("e"), m);
  gw.remove(KymaEnvironmentId("e"), "Function", "shop", "f");
  gw.remove(KymaEnvironmentId("e"), "Function", "shop", "g");
  assert(gw.operations.length == 2 && gw.operations[0].verb == "delete");
}
