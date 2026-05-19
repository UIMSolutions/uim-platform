# Customer Identity Service — UML Diagrams

## Domain Entity Class Diagram

```plantuml
@startuml CustomerIdentity_Domain

package "uim.platform.customer_identity.domain" {

  class Customer {
    + id : CustomerId
    + tenantId : TenantId
    + email : string
    + phone : string
    + firstName : string
    + lastName : string
    + passwordHash : string
    + status : CustomerStatus
    + loginProvider : LoginProvider
    + locale : string
    + country : string
    + birthDate : string
    + gender : CustomerGender
    + profileData : string
    + progressiveData : string
    + emailVerified : bool
    + phoneVerified : bool
    + lastLoginAt : long
    + lastLoginIp : string
  }

  class CustomerSession {
    + id : CustomerSessionId
    + tenantId : TenantId
    + customerId : CustomerId
    + token : string
    + deviceInfo : string
    + ipAddress : string
    + userAgent : string
    + expiresAt : long
    + status : SessionStatus
  }

  class SocialIdentity {
    + id : SocialIdentityId
    + tenantId : TenantId
    + customerId : CustomerId
    + provider : LoginProvider
    + providerUserId : string
    + providerEmail : string
    + displayName : string
    + accessToken : string
    + refreshToken : string
    + tokenExpiresAt : long
    + profileData : string
    + status : SocialIdentityStatus
  }

  class ConsentRecord {
    + id : ConsentRecordId
    + tenantId : TenantId
    + customerId : CustomerId
    + consentType : ConsentType
    + purpose : string
    + legalBasis : LegalBasis
    + granted : bool
    + grantedAt : long
    + revokedAt : long
    + ipAddress : string
    + userAgent : string
    + version_ : string
    + locale : string
  }

  class AuditLog {
    + id : AuditLogId
    + tenantId : TenantId
    + actorId : string
    + action : AuditAction
    + resourceType : ResourceType
    + resourceId : string
    + ipAddress : string
    + userAgent : string
    + timestamp : long
    + details : string
    + success : bool
  }

  class IdentityProvider {
    + id : IdentityProviderId
    + tenantId : TenantId
    + name : string
    + description : string
    + providerType : IdentityProviderType
    + clientId : string
    + clientSecret : string
    + issuerUrl : string
    + metadataUrl : string
    + redirectUri : string
    + attributeMapping : string
    + scopes : string
    + status : IdentityProviderStatus
  }

  class ScreenSet {
    + id : ScreenSetId
    + tenantId : TenantId
    + name : string
    + description : string
    + flowType : ScreenSetFlowType
    + htmlContent : string
    + cssContent : string
    + jsContent : string
    + locale : string
    + version_ : string
    + status : ScreenSetStatus
  }

  class SitePolicy {
    + id : SitePolicyId
    + tenantId : TenantId
    + name : string
    + description : string
    + policyType : PolicyType
    + passwordMinLength : int
    + passwordComplexity : PasswordComplexity
    + sessionTimeoutSeconds : int
    + mfaRequired : bool
    + mfaMethod : MfaMethod
    + captchaEnabled : bool
    + socialLoginEnabled : bool
    + progressiveProfilingEnabled : bool
    + maxLoginAttempts : int
    + lockoutDurationSeconds : int
    + emailVerificationRequired : bool
    + version_ : string
  }

  Customer "1" --> "0..*" CustomerSession : has
  Customer "1" --> "0..*" SocialIdentity : links
  Customer "1" --> "0..*" ConsentRecord : has
  AuditLog --> Customer : tracks
  IdentityProvider --> SocialIdentity : backs
}

@enduml
```

## Sequence Diagrams

### Customer Registration Flow

```plantuml
@startuml Registration_Flow

actor Client
participant "CustomerController" as CC
participant "ManageCustomersUseCase" as UC
participant "ICustomerRepository" as Repo
participant "IdentityValidator" as Val

Client -> CC : POST /api/v1/customer-identity/customers\n{email, password, firstName, lastName}
CC -> UC : registerCustomer(dto)
UC -> Val : validateCustomer(customer)
Val --> UC : valid
UC -> Repo : findByEmail(tenantId, email)
Repo --> UC : null (not found)
UC -> Repo : add(customer)
Repo --> UC : ok
UC --> CC : CommandResult(success=true, id)
CC --> Client : 201 Created {id}

@enduml
```

### Social Login / Account Linking Flow

```plantuml
@startuml SocialLogin_Flow

actor Client
participant "SocialIdentityController" as SIC
participant "ManageSocialIdentitiesUseCase" as UC
participant "ISocialIdentityRepository" as Repo
participant "ManageCustomersUseCase" as CUC

Client -> SIC : POST /api/v1/customer-identity/social-identities\n{customerId, provider, providerUserId, accessToken}
SIC -> UC : linkSocialIdentity(dto)
UC -> CUC : getCustomer(tenantId, customerId)
CUC --> UC : Customer
UC -> Repo : findByProviderAndUser(tenantId, provider, providerUserId)
Repo --> UC : null (not yet linked)
UC -> Repo : add(socialIdentity)
Repo --> UC : ok
UC --> SIC : CommandResult(success=true, id)
SIC --> Client : 201 Created {id}

@enduml
```

### Consent Grant Flow

```plantuml
@startuml Consent_Flow

actor Client
participant "ConsentRecordController" as CRC
participant "ManageConsentRecordsUseCase" as UC
participant "IConsentRecordRepository" as Repo

Client -> CRC : POST /api/v1/customer-identity/consents\n{customerId, consentType, purpose, legalBasis, granted=true}
CRC -> UC : grantConsent(dto)
UC -> Repo : add(consentRecord)
Repo --> UC : ok
UC --> CRC : CommandResult(success=true, id)
CRC --> Client : 201 Created {id}

@enduml
```

### Identity Provider Federation (OIDC/SAML)

```plantuml
@startuml IdP_Federation_Flow

actor "Customer Browser" as B
participant "Screen Set UI" as UI
participant "IdentityProviderController" as IPC
participant "ManageIdentityProvidersUseCase" as UC
database "IdentityProvider Store" as Store

B -> UI : Click "Login with Corporate SSO"
UI -> IPC : GET /api/v1/customer-identity/identity-providers
IPC -> UC : listActive(tenantId)
UC -> Store : findByStatus(tenantId, active)
Store --> UC : [IdentityProvider...]
UC --> IPC : providers
IPC --> UI : provider list
UI -> B : Redirect to IdP authorize URL
note right: Browser follows OIDC/SAML redirect
B -> UI : IdP callback with token/assertion
UI -> IPC : POST /api/v1/customer-identity/social-identities
note right: Link IdP identity to customer

@enduml
```
