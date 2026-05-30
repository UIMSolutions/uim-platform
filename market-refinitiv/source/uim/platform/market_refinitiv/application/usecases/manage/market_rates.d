/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.application.usecases.manage.market_rates;
import uim.platform.market_refinitiv;


mixin(ShowModule!());

@safe:

class ManageMarketRatesUseCase {
  private MarketRateRepository rateRepo;
  private AuditLogRepository   auditRepo;

  this(MarketRateRepository rateRepo, AuditLogRepository auditRepo) {
    this.rateRepo  = rateRepo;
    this.auditRepo = auditRepo;
  }

  // Upload (inbound port – driving adapter calls this)
  UploadRatesResponse upload(UploadRatesRequest req) {
    string[] errors;
    MarketRate[] accepted;

    // Quota: batch size
    auto quotaErr = QuotaService.checkBatchSize(req.records.length);
    if (quotaErr.length > 0) {
      logAudit(req.tenantId, req.requestedBy, AuditOperation.upload, "",
               MarketDataCategory.exchangeRates, OperationStatus.failed, quotaErr, 0, "", "");
      return UploadRatesResponse(OperationStatus.failed, 0, cast(int) req.records.length, [quotaErr]);
    }

    foreach (rec; req.records) {
      MarketRate rate;
      rate.initEntity(req.tenantId);
      rate.providerCode       = rec.providerCode;
      rate.dataSource         = rec.dataSource;
      rate.key1               = rec.key1;
      rate.key2               = rec.key2;
      rate.marketDataProperty = rec.marketDataProperty;
      rate.effectiveDate      = rec.effectiveDate;
      rate.effectiveTime      = rec.effectiveTime;
      rate.marketDataValue    = rec.marketDataValue;
      rate.securityCurrency   = rec.securityCurrency;
      rate.fromFactor         = rec.fromFactor;
      rate.toFactor           = rec.toFactor;
      rate.additionalKey      = rec.additionalKey;

      // Parse category
      bool categorySet = false;
      static foreach (member; __traits(allMembers, MarketDataCategory)) {
        if (!categorySet && (cast(string) __traits(getMember, MarketDataCategory, member)) == rec.category) {
          rate.category  = __traits(getMember, MarketDataCategory, member);
          categorySet = true;
        }
      }
      if (!categorySet) {
        errors ~= "Unknown category code: " ~ rec.category;
        continue;
      }

      // Parse priceQuotation
      rate.priceQuotation = rec.priceQuotation == "indirect"
        ? PriceQuotation.indirect
        : PriceQuotation.direct;

      // Validate
      auto err = MarketRateValidator.validateRate(rate);
      if (err.length > 0) {
        errors ~= err;
        continue;
      }

      accepted ~= rate;
    }

    if (accepted.length > 0)
      rateRepo.saveAll(accepted);

    auto status = errors.length == 0
      ? OperationStatus.success
      : (accepted.length > 0 ? OperationStatus.warning : OperationStatus.failed);

    logAudit(req.tenantId, req.requestedBy, AuditOperation.upload,
             req.records.length > 0 ? req.records[0].providerCode : "",
             req.records.length > 0
               ? cast(MarketDataCategory)(req.records[0].category)
               : MarketDataCategory.exchangeRates,
             status, errors.length > 0 ? errors[0] : "OK",
             cast(int) accepted.length, "", "");

    return UploadRatesResponse(status,
      cast(int) accepted.length,
      cast(int) errors.length,
      errors);
  }

  // Download (outbound port – returns rates to calling system)
  DownloadRatesResponse download(DownloadRatesRequest req) {
    MarketRate[] result;

    foreach (instr; req.instruments) {
      MarketDataCategory cat;
      bool found = false;
      static foreach (member; __traits(allMembers, MarketDataCategory)) {
        if (!found && (cast(string) __traits(getMember, MarketDataCategory, member)) == instr.category) {
          cat = __traits(getMember, MarketDataCategory, member);
          found = true;
        }
      }
      if (!found) continue;

      MarketRate[] rates;
      if (req.latestOnly) {
        rates = rateRepo.findLatest(req.tenantId, req.providerCode, cat);
      } else if (req.fromDate.length > 0 || req.toDate.length > 0) {
        rates = rateRepo.findByDateRange(req.tenantId, req.fromDate, req.toDate);
      } else {
        rates = rateRepo.findByKey(req.tenantId, instr.key1, instr.key2, cat);
      }
      result ~= rates;
    }

    logAudit(req.tenantId, req.requestedBy, AuditOperation.download,
             req.providerCode,
             req.instruments.length > 0
               ? cast(MarketDataCategory)(req.instruments[0].category)
               : MarketDataCategory.exchangeRates,
             OperationStatus.success, "OK",
             cast(int) result.length, req.fromDate, req.toDate);

    return DownloadRatesResponse(OperationStatus.success, result, cast(int) result.length);
  }

  // Query (management UI)
  MarketRate[] query(QueryRatesRequest req) {
    if (req.key1.length > 0) {
      MarketDataCategory cat;
      static foreach (member; __traits(allMembers, MarketDataCategory)) {
        if ((cast(string) __traits(getMember, MarketDataCategory, member)) == req.category) {
          cat = __traits(getMember, MarketDataCategory, member);
        }
      }
      return rateRepo.findByKey(req.tenantId, req.key1, req.key2, cat);
    }
    if (req.providerCode.length > 0)
      return rateRepo.findByProvider(req.tenantId, req.providerCode);

    return rateRepo.findByTenant(req.tenantId);
  }

  MarketRate getById(TenantId tenantId, MarketRateId id) {
    return rateRepo.findById(tenantId, id);
  }

  CommandResult deleteRate(DeleteRatesRequest req) {
    if (req.fromDate.length > 0 || req.toDate.length > 0) {
      rateRepo.removeByDateRange(req.tenantId, req.fromDate, req.toDate);
    } else if (req.providerCode.length > 0) {
      rateRepo.removeByProvider(req.tenantId, req.providerCode);
    } else {
      return CommandResult(false, "", "Either providerCode or date range is required for deletion");
    }

    logAudit(req.tenantId, req.requestedBy, AuditOperation.delete_,
             req.providerCode, MarketDataCategory.exchangeRates,
             OperationStatus.success, "Deleted", 0, req.fromDate, req.toDate);

    return CommandResult(true, "", "");
  }

  // ---------------------------------------------------------------------------
  private void logAudit(TenantId tenantId, string requestedBy,
                         AuditOperation op, string providerCode,
                         MarketDataCategory category, OperationStatus status,
                         string message, int recordCount,
                         string fromDate, string toDate) {
    AuditLog entry;
    entry.initEntity(tenantId);
    entry.operation   = op;
    entry.requestedBy = requestedBy;
    entry.providerCode = providerCode;
    entry.category    = category;
    entry.status      = status;
    entry.message     = message;
    entry.recordCount = recordCount;
    entry.fromDate    = fromDate;
    entry.toDate      = toDate;
    auditRepo.save(entry);
  }
}
