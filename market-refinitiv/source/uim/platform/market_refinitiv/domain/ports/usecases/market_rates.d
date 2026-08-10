/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.market_rates;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

interface IManageMarketRatesUseCase {
  
  // Upload (inbound port – driving adapter calls this)
  UploadRatesResponse upload(UploadRatesRequest req);
  DownloadRatesResponse download(DownloadRatesRequest req);
  MarketRate[] queryRates(QueryRatesRequest req);
  MarketRate getRate(TenantId tenantId, MarketRateId id);
  CommandResult deleteRate(DeleteRatesRequest req);

}