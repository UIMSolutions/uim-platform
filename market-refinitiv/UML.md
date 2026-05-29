# UML – Market Rates Management BYOR Service

## 1. Package / Layer Diagram

```
┌──────────────────────────────────────────────────────────┐
│                   <<module>>                              │
│             uim.platform.market_refinitiv                      │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │ presentation.http                                │    │
│  │  + MarketRateController                          │    │
│  │  + AuditLogController                            │    │
│  │  + HealthController                              │    │
│  │  + json_utils                                    │    │
│  └──────────────┬──────────────────────────────────┘    │
│                 │ uses                                    │
│  ┌──────────────▼──────────────────────────────────┐    │
│  │ application                                       │    │
│  │  + ManageMarketRatesUseCase                       │    │
│  │  + ManageProvidersUseCase                         │    │
│  │  + ManageAuditLogsUseCase                         │    │
│  │  + DTO: Upload/Download/Query/Delete Requests     │    │
│  └──────────────┬──────────────────────────────────┘    │
│                 │ uses                                    │
│  ┌──────────────▼──────────────────────────────────┐    │
│  │ domain                                            │    │
│  │  entities: MarketRate, Provider, AuditLog         │    │
│  │  types:    MarketDataCategory, OperationStatus …  │    │
│  │  ports:    MarketRateRepository (interface)        │    │
│  │            ProviderRepository (interface)          │    │
│  │            AuditLogRepository (interface)          │    │
│  │  services: MarketRateValidator, QuotaService       │    │
│  └──────────────▲──────────────────────────────────┘    │
│                 │ implements                              │
│  ┌──────────────┴──────────────────────────────────┐    │
│  │ infrastructure                                    │    │
│  │  + MemoryMarketRateRepository                     │    │
│  │  + MemoryProviderRepository                       │    │
│  │  + MemoryAuditLogRepository                       │    │
│  │  + AppConfig / loadConfig()                       │    │
│  │  + Container / buildContainer()                   │    │
│  └─────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Entity Class Diagram

```
┌──────────────────────┐        ┌──────────────────────┐
│ <<struct>>           │        │ <<struct>>            │
│ MarketRate           │        │ Provider              │
├──────────────────────┤        ├──────────────────────┤
│ + id: MarketRateId   │        │ + id: ProviderId      │
│ + tenantId: TenantId │        │ + tenantId: TenantId  │
│ + providerCode: str  │        │ + code: string        │
│ + dataSource: str    │        │ + name: string        │
│ + category: Category │        │ + description: str    │
│ + key1: string       │        │ + contactEmail: str   │
│ + key2: string       │        │ + isActive: bool      │
│ + marketDataProperty │        └──────────────────────┘
│ + effectiveDate: str │
│ + effectiveTime: str │        ┌──────────────────────┐
│ + marketDataValue: f │        │ <<struct>>            │
│ + securityCurrency   │        │ AuditLog              │
│ + fromFactor: int    │        ├──────────────────────┤
│ + toFactor: int      │        │ + id: AuditLogId      │
│ + priceQuotation     │        │ + tenantId: TenantId  │
│ + additionalKey: str │        │ + operation: enum     │
│ + createdAt: long    │        │ + requestedBy: str    │
│ + updatedAt: long    │        │ + providerCode: str   │
└──────────────────────┘        │ + category: enum      │
                                 │ + status: enum        │
                                 │ + message: string     │
                                 │ + recordCount: int    │
                                 │ + fromDate: string    │
                                 │ + toDate: string      │
                                 └──────────────────────┘
```

---

## 3. Use Case Interaction Diagram

### Upload flow

```
Client                  MarketRateController         ManageMarketRatesUseCase
  │                              │                            │
  │──POST /upload──────────────►│                            │
  │                              │──upload(req)─────────────►│
  │                              │                            │──QuotaService.check()
  │                              │                            │──MarketRateValidator.validate() per record
  │                              │                            │──MarketRateRepository.saveAll()
  │                              │                            │──AuditLogRepository.save()
  │                              │◄──UploadRatesResponse─────│
  │◄──200 JSON──────────────────│                            │
```

### Download flow

```
Client                  MarketRateController         ManageMarketRatesUseCase
  │                              │                            │
  │──POST /download────────────►│                            │
  │                              │──download(req)────────────►│
  │                              │                            │──MarketRateRepository.findByKey/Latest/DateRange()
  │                              │                            │──AuditLogRepository.save()
  │                              │◄──DownloadRatesResponse───│
  │◄──200 JSON (rates array)────│                            │
```

---

## 4. Repository Port / Adapter Pattern

```
        ┌──────────────────────────────┐
        │  <<interface>>               │
        │  MarketRateRepository        │
        │                              │
        │  + findById()                │
        │  + findByTenant()            │
        │  + findByProvider()          │
        │  + findByCategory()          │
        │  + findByDateRange()         │
        │  + findByKey()               │
        │  + findLatest()              │
        │  + saveAll()                 │
        │  + removeByProvider()        │
        └──────────────┬───────────────┘
                       │ implements
        ┌──────────────▼───────────────┐
        │  MemoryMarketRateRepository  │
        │  (in-memory HashMap)         │
        └──────────────────────────────┘
```

---

## 5. Sequence – Provider Registration

```
POST /providers        MarketRateController   ManageProvidersUseCase   ProviderRepository
        │                      │                       │                       │
        │────────────────────►│                       │                       │
        │                      │──createProvider(req)─►│                       │
        │                      │                       │──codeExists()────────►│
        │                      │                       │◄──false───────────────│
        │                      │                       │──save(provider)──────►│
        │                      │◄──CommandResult(ok)───│                       │
        │◄──201 { id }─────────│                       │                       │
```

---

## 6. Enum Types

```
MarketDataCategory        OperationStatus       AuditOperation
───────────────────       ───────────────       ──────────────
exchangeRates   = "01"    pending               upload
securities      = "02"    processing            download
interestRates   = "03"    success               delete_
indexes         = "04"    warning               query
basisSpread     = "09"    failed
creditSpread    = "10"
forexSwapRates  = "21"
generalVola     = "30"    PriceQuotation
exchangeRateVola= "31"    ──────────────
securityVola    = "32"    direct
interestRateVola= "33"    indirect
indexVola       = "34"
```
