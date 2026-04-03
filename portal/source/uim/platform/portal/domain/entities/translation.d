module uim.platform.xyz.domain.entities.translation;

import domain.types;

/// Translation entry for portal content (i18n).
struct Translation
{
    TranslationId id;
    TenantId tenantId;
    string resourceType;  // "site", "page", "tile", "section", "menuItem"
    string resourceId;     // ID of the resource
    string fieldName;      // "title", "description", etc.
    string language;       // ISO 639-1 code (e.g., "de", "fr")
    string value;          // translated text
    long createdAt;
    long updatedAt;
}
