/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.ports.usecases.market_rates;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

interface IManageMarketRatesUseCase {

  UploadRatesResponse uploadRates(UploadRatesRequest req);
  DownloadRatesResponse downloadRates(DownloadRatesRequest req);
  MarketRate[] queryRates(QueryRatesRequest req);
  MarketRate getRate(TenantId tenantId, MarketRateId id);
  UsecaseResult deleteRate(DeleteRatesRequest req);

}