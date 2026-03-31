module uim.platform.analytics.domain.values.common;

import uim.platform.analytics;

@safe:
/// Strongly-typed identifier wrapping a UUID string.
struct EntityId {
    string value;

    static EntityId generate() {
        return EntityId(randomUUID().toString());
    }

    bool opEquals(const EntityId other) const {
        return value == other.value;
    }

    size_t toHash() const nothrow @safe {
        size_t hash;
        foreach (c; value)
            hash = hash * 31 + c;
        return hash;
    }

    bool empty() const {
        return value.length == 0;
    }

    Json toJson() const {
        return value.toJson;
    }
}

/// Audit metadata attached to every domain entity.
struct AuditInfo {
    SysTime createdAt;
    string createdBy;
    SysTime updatedAt;
    string updatedBy;

    static AuditInfo create(string userId) {
        auto now = Clock.currTime();
        return AuditInfo(now, userId, now, userId);
    }

    AuditInfo touch(string userId) const {
        return AuditInfo(createdAt, createdBy, Clock.currTime(), userId);
    }


    Json toJson() const {
        return Json([
            "createdAt": createdAt.toISOExtString(),
            "createdBy": createdBy,
            "updatedAt": updatedAt.toISOExtString(),
            "updatedBy": updatedBy
        ]);
    }
}

/// Sharing / visibility scope.
enum Visibility {
    Private,
    Team,
    Organization,
    Public,
}

/// Status of an analytical artifact.
enum ArtifactStatus {
    Draft,
    Published,
    Archived,
}
