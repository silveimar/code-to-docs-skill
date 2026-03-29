---
title: Encryption Wrapper
type: pattern
language:
  - "typescript"
status: generated
complexity: medium
dependencies:
  - "[[Database]]"
  - "[[Infrastructure Services]]"
related-notes:
  - "[[Auth and Security]]"
canonical-source: src/lib/server/encryption.ts
generated-by: code-to-docs
generated-at: 2026-03-28T12:00:00Z
mode: full
tags:
  - code-docs
  - pattern
---

# Encryption Wrapper

Transparent field-level encryption applied consistently across all database operations that handle sensitive data.

## Beginner

> [!tip] Prerequisites
> Before reading this section, you should be comfortable with:
> - What encryption means (making data unreadable without a key)
> - Why passwords and tokens shouldn't be stored in plain text

### What Is This?

When Dockhand stores sensitive data (passwords, API tokens, TLS keys, SSH keys), it encrypts them before writing to the database and decrypts them when reading back. This happens automatically in the database module's functions — callers never see encrypted values.

### How It Works

```
Write: plaintext → encrypt() → "enc:v1:base64(...)" → database
Read:  database → "enc:v1:base64(...)" → decrypt() → plaintext
```

## Intermediate

### Where It Appears

The pattern is applied to these field types across `db.ts`:
- Environment TLS keys and Hawser tokens
- Registry passwords
- LDAP bind passwords
- OIDC client secrets
- Git credentials (passwords, SSH keys, passphrases)
- Notification channel configs (SMTP passwords)

### Implementation

- **Algorithm**: AES-256-GCM (authenticated encryption with associated data)
- **Key source**: File-based (`DATA_DIR/encryption.key`) or environment variable (`ENCRYPTION_KEY`), with auto-generation on first use
- **Format**: `enc:v1:<base64(iv + authTag + ciphertext)>` — the `enc:v1:` prefix enables detection and backward compatibility
- **Key rotation**: When the env var differs from the file key, `migrateCredentials()` re-encrypts all sensitive fields with the new key

### Why This Pattern

Field-level encryption (vs. whole-database encryption) allows the database to be queried normally for non-sensitive columns while protecting specific fields. It also survives database backup/restore without requiring the backup tool to understand encryption.

## Advanced

### Failure Modes

- **Key lost**: All encrypted fields become unreadable. `decrypt()` returns `null`, and callers pass through the garbled value or fail silently.
- **Key rotation interrupted**: If `migrateCredentials()` crashes mid-rotation, some fields use the old key and some use the new key. Recovery requires manually running migration with the old key available.
- **Plain text fallback**: `decrypt()` detects the `enc:v1:` prefix. Values without it are returned as-is. This handles legacy data that was stored before encryption was enabled, but also means a failed encryption silently stores plain text.
