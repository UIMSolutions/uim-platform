module uim.platform.service.helpers.convert;
import uim.platform.service;

mixin(ShowModule!());

@safe:
private Json toJsonArray(string[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}

Json toJsonArray(SAPEntity[] metrics) {
  return metrics.map!(m => m.toJson()).array.toJson;
}

private Json toJsonArray(T)(T[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}
