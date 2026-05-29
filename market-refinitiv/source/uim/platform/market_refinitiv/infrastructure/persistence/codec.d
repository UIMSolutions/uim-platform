module uim.platform.market_refinitiv.infrastructure.persistence.codec;

import uim.platform.market_refinitiv;
import vibe.data.json : Json;
import std.conv : to;
import std.traits : EnumMembers;

@safe:

private string getString(Json j, string key, string def = "") {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isString) return v.get!string;
  if (v.isInteger) return v.get!long.to!string;
  if (v.isFloat) return v.get!double.to!string;
  if (v.isBoolean_) return v.get!bool.to!string;
  return def;
}

private int getInt(Json j, string key, int def = 0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isInteger) return cast(int) v.get!long;
  if (v.isFloat) return cast(int) v.get!double;
  return def;
}

private long getLong(Json j, string key, long def = 0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isInteger) return v.get!long;
  if (v.isFloat) return cast(long) v.get!double;
  return def;
}

private double getDouble(Json j, string key, double def = 0.0) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isFloat) return v.get!double;
  if (v.isInteger) return cast(double) v.get!long;
  return def;
}

private bool getBool(Json j, string key, bool def = false) {
  if (j.type != Json.Type.object) return def;
  auto v = j[key];
  if (v.isBoolean_) return v.get!bool;
  return def;
}

private E parseEnumOrDefault(E)(string value, E deflt) {
  if (value.length == 0) return deflt;
  try {
    return value.to!E;
  } catch (Exception) {
    foreach (member; EnumMembers!E) {
      if (member.to!string == value || cast(string) member == value) {
        return member;
      }
    }
    return deflt;
  }
}

Json toJsonDoc(MarketRate r) {
  return r.toJson();
}

Json toJsonDoc(Provider p) {
  return p.toJson();
}

Json toJsonDoc(AuditLog l) {
  return l.toJson();
}

MarketRate marketRateFromJson(Json j) {
  MarketRate r;
  r.id = MarketRateId(getString(j, "id"));
  r.tenantId = TenantId(getString(j, "tenantId"));
  r.createdAt = getLong(j, "createdAt");
  r.updatedAt = getLong(j, "updatedAt");
  r.createdBy = getString(j, "createdBy");
  r.updatedBy = getString(j, "updatedBy");
  r.providerCode = getString(j, "providerCode");
  r.dataSource = getString(j, "dataSource");
  r.category = parseEnumOrDefault!MarketDataCategory(getString(j, "category"), MarketDataCategory.exchangeRates);
  r.key1 = getString(j, "key1");
  r.key2 = getString(j, "key2");
  r.marketDataProperty = getString(j, "marketDataProperty");
  r.effectiveDate = getString(j, "effectiveDate");
  r.effectiveTime = getString(j, "effectiveTime");
  r.marketDataValue = getDouble(j, "marketDataValue");
  r.securityCurrency = getString(j, "securityCurrency");
  r.fromFactor = getInt(j, "fromFactor", 1);
  r.toFactor = getInt(j, "toFactor", 1);
  r.priceQuotation = parseEnumOrDefault!PriceQuotation(getString(j, "priceQuotation"), PriceQuotation.direct);
  r.additionalKey = getString(j, "additionalKey");
  return r;
}

Provider providerFromJson(Json j) {
  Provider p;
  p.id = ProviderId(getString(j, "id"));
  p.tenantId = TenantId(getString(j, "tenantId"));
  p.createdAt = getLong(j, "createdAt");
  p.updatedAt = getLong(j, "updatedAt");
  p.createdBy = getString(j, "createdBy");
  p.updatedBy = getString(j, "updatedBy");
  p.code = getString(j, "code");
  p.name = getString(j, "name");
  p.description = getString(j, "description");
  p.contactEmail = getString(j, "contactEmail");
  p.isActive = getBool(j, "isActive", true);
  return p;
}

AuditLog auditLogFromJson(Json j) {
  AuditLog l;
  l.id = AuditLogId(getString(j, "id"));
  l.tenantId = TenantId(getString(j, "tenantId"));
  l.createdAt = getLong(j, "createdAt");
  l.updatedAt = getLong(j, "updatedAt");
  l.createdBy = getString(j, "createdBy");
  l.updatedBy = getString(j, "updatedBy");
  l.operation = parseEnumOrDefault!AuditOperation(getString(j, "operation"), AuditOperation.query);
  l.requestedBy = getString(j, "requestedBy");
  l.providerCode = getString(j, "providerCode");
  l.category = parseEnumOrDefault!MarketDataCategory(getString(j, "category"), MarketDataCategory.exchangeRates);
  l.status = parseEnumOrDefault!OperationStatus(getString(j, "status"), OperationStatus.success);
  l.message = getString(j, "message");
  l.recordCount = getInt(j, "recordCount");
  l.fromDate = getString(j, "fromDate");
  l.toDate = getString(j, "toDate");
  return l;
}
