module uim.platform.integration_suite.domain.entities.trading_partner;
import uim.platform.integration_suite;
// mixin(ShowModule!());
@safe:

/// A B2B trading partner profile capturing EDI and messaging preferences.
struct TradingPartner {
  mixin TenantEntity!(TradingPartnerId);

  string        name;
  string        description;
  PartnerType   partnerType;
  B2bStandard   standard;
  string        systemId;
  string        contactEmail;
  string        contactName;
  bool          active;
  string[]      agreementIds;
  string[string] metadata;

  Json toJson() const {
    auto j = entityToJson();
    j["name"]         = Json(name);
    j["description"]  = Json(description);
    j["partnerType"]  = Json(cast(string) partnerType);
    j["standard"]     = Json(cast(string) standard);
    j["systemId"]     = Json(systemId);
    j["contactEmail"] = Json(contactEmail);
    j["contactName"]  = Json(contactName);
    j["active"]       = Json(active);
    j["agreementIds"] = jsonStrArray(agreementIds);
    j["metadata"]     = jsonKeyValuePairs(metadata);
    return j;
  }
}
