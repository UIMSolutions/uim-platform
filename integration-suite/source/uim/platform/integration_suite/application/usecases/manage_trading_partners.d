module uim.platform.integration_suite.application.usecases.manage_trading_partners;
import uim.platform.integration_suite;
import std.conv : to;
mixin(ShowModule!());
@safe:

class ManageTradingPartnersUseCase {
private:
  TradingPartnerRepository _repo;

public:
  this(TradingPartnerRepository repo) { _repo = repo; }

  CommandResult create(CreateTradingPartnerRequest req) {
    auto tp = TradingPartner();
    initEntity(tp, req.tenantId, req.id);
    tp.name         = req.name;
    tp.description  = req.description;
    tp.partnerType  = req.partnerType.length > 0 ? req.partnerType.to!PartnerType : PartnerType.tradingPartner;
    tp.standard     = req.standard.length > 0 ? req.standard.to!B2bStandard : B2bStandard.xml_;
    tp.systemId     = req.systemId;
    tp.contactEmail = req.contactEmail;
    tp.contactName  = req.contactName;
    tp.active       = true;
    tp.metadata     = req.metadata;
    auto err = IntegrationValidator.validateTradingPartner(tp);
    if (err !is null) return CommandResult(false, err);
    _repo.add(getTenantId(req.tenantId), tp);
    return CommandResult(true, tp.toJson());
  }

  CommandResult getAll(string tenantId) {
    auto items = _repo.getAll(getTenantId(tenantId));
    auto arr = Json.emptyArray;
    foreach (p; items) arr ~= p.toJson();
    return CommandResult(true, arr);
  }

  CommandResult getById(string tenantId, string id) {
    auto tp = _repo.getById(getTenantId(tenantId), TradingPartnerId(id));
    if (tp.isNull) return CommandResult(false, "Trading partner not found");
    return CommandResult(true, tp.toJson());
  }

  CommandResult update(UpdateTradingPartnerRequest req) {
    auto tp = _repo.getById(getTenantId(req.tenantId), TradingPartnerId(req.id));
    if (tp.isNull) return CommandResult(false, "Trading partner not found");
    if (req.name.length > 0)         tp.name         = req.name;
    if (req.contactEmail.length > 0) tp.contactEmail = req.contactEmail;
    if (req.contactName.length > 0)  tp.contactName  = req.contactName;
    if (req.standard.length > 0)     tp.standard     = req.standard.to!B2bStandard;
    tp.active = req.active;
    foreach (k, v; req.metadata)     tp.metadata[k]  = v;
    _repo.update(getTenantId(req.tenantId), tp);
    return CommandResult(true, tp.toJson());
  }

  CommandResult remove(string tenantId, string id) {
    auto tp = _repo.getById(getTenantId(tenantId), TradingPartnerId(id));
    if (tp.isNull) return CommandResult(false, "Trading partner not found");
    _repo.remove(getTenantId(tenantId), TradingPartnerId(id));
    return CommandResult(true, "Trading partner deleted");
  }
}
