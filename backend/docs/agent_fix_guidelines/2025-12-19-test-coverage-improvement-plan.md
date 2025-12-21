# Test Coverage Improvement Plan

**Date:** 2025-12-19  
**Status:** Proposed  
**Priority:** High

## Overview

This document outlines the test coverage gaps identified in the backend codebase and proposes additional test cases to ensure comprehensive testing of all API endpoints.

## Current Test Coverage Status

### vitest (Unit Tests)
- ✅ **categories**: 4 tests (POST, GET /, GET /:id, PUT)
- ✅ **tags**: 4 tests (POST, GET /, GET /:id, PUT)
- ⚠️ **links**: 1 test only (GET /:id)
- ❌ **notes**: 0 tests
- ❌ **purchases**: 0 tests
- ❌ **url**: 0 tests

### runn (E2E Tests)
- ✅ **categories**: 2 tests (GET /, POST /)
- ✅ **links**: 1 test (POST /)
- ✅ **url**: 1 test (POST /title)
- ❌ **tags**: 0 tests
- ❌ **notes**: 0 tests
- ❌ **purchases**: 0 tests

## Proposed Test Cases

### 1. vitest - Unit Tests (Priority: High)

#### links (1 → 6 tests)
**Current:** GET /:id only

**Required additions:**
- ✅ POST / (normal) - Create link
- ✅ POST / with tag_ids (normal) - Create link with tags
- ✅ GET / (normal) - Get links by date range
- ✅ PUT /:id (normal) - Update link
- ⚠️ POST / without required fields (error) - Validation error

**Implementation notes:**
```typescript
// Use beforeEach to create test data
// Test date range filtering with start_date and end_date
// Verify tag_ids association works correctly
```

#### notes (0 → 4 tests)
**Current:** No tests

**Required additions:**
- ✅ POST / (normal) - Create note
- ✅ POST / with tag_ids (normal) - Create note with tags
- ✅ GET / (normal) - Get notes by date range
- ⚠️ POST / without required fields (error) - Validation error

**Schema reference:**
```typescript
{
  title: string (1-2048 chars, required),
  text: string (1-8192 chars, required),
  tag_ids?: number[]
}
```

#### purchases (0 → 4 tests)
**Current:** No tests

**Required additions:**
- ✅ POST / (normal) - Create purchase
- ✅ POST / with category_id (normal) - Create purchase with category
- ✅ GET / (normal) - Get purchases by date range
- ⚠️ POST / without required fields (error) - Validation error

**Schema reference:**
```typescript
{
  title: string (1-2048 chars, required),
  cost: number (required),
  category_id?: number
}
```

#### url (0 → 2 tests)
**Current:** No tests

**Required additions:**
- ✅ POST /title (normal) - Extract title and OGP from URL
- ⚠️ POST /title with invalid URL (error) - Invalid URL format

**Expected response:**
```typescript
{
  title: string,
  url: string,
  description?: string,
  image?: string,
  site_name?: string
}
```

### 2. runn - E2E Tests (Priority: Medium)

#### categories (2 → 4 tests)
**Current:** GET /, POST /

**Required additions:**
- GET /:id (normal) - Get category by ID
- PUT / (normal) - Update category

#### tags (0 → 4 tests)
**Current:** No tests

**Required additions:**
- GET / (normal) - Get all tags
- POST / (normal) - Create tag
- GET /:id (normal) - Get tag by ID
- PUT / (normal) - Update tag

**Test file locations:**
```
test/runn/tags/get.yml
test/runn/tags/post.yml
test/runn/tags/get-by-id.yml
test/runn/tags/put.yml
```

#### links (1 → 4 tests)
**Current:** POST /

**Required additions:**
- GET / (normal) - Get links by date range with query params
- GET /:id (normal) - Get link by ID
- PUT /:id (normal) - Update link

**Query params example:**
```yaml
query:
  start_date: "2025-01-01"
  end_date: "2025-12-31"
```

#### notes (0 → 2 tests)
**Current:** No tests

**Required additions:**
- POST / (normal) - Create note
- GET / (normal) - Get notes by date range

**Test file locations:**
```
test/runn/notes/post.yml
test/runn/notes/get.yml
```

#### purchases (0 → 2 tests)
**Current:** No tests

**Required additions:**
- POST / (normal) - Create purchase
- GET / (normal) - Get purchases by date range

**Test file locations:**
```
test/runn/purchases/post.yml
test/runn/purchases/get.yml
```

## Implementation Priority

### Phase 1: Critical (Immediate)
1. **links vitest** - Router exists but only 1 test
2. **notes vitest** - Router exists but 0 tests
3. **purchases vitest** - Router exists but 0 tests
4. **url vitest** - New feature, requires tests

### Phase 2: Important (Next)
5. **tags runn** - E2E coverage for main flows
6. **links runn** - Complete E2E coverage
7. **categories runn** - Add missing endpoints

### Phase 3: Nice to have
8. **notes runn** - Basic create/list coverage
9. **purchases runn** - Basic create/list coverage

## Test Guidelines

### vitest Tests
- Use `beforeEach` to set up test data for each test
- Use `createdId` pattern to track created resources
- Test normal paths are mandatory
- At least one validation error test per router
- Use `.toBeGreaterThanOrEqual()` for list length assertions

### runn Tests
- Test against `http://localhost:8787`
- Always verify status code and Content-Type header
- Use realistic test data
- Keep tests independent (don't rely on previous test data)
- File naming: `<resource>/<action>.yml`

## Notes

- All routers have been identified and mapped
- Test patterns established in categories/tags can be reused
- Date range queries use format: `YYYY-MM-DD`
- Tag/category associations should be tested
- Validation schemas already defined in types files

## References

- Existing test files:
  - `/src/v1/categories/router.test.ts`
  - `/src/v1/tags/router.test.ts`
  - `/src/v1/links/router.test.ts`
  - `/test/runn/categories/*.yml`
  - `/test/runn/links/*.yml`
  - `/test/runn/url/*.yml`
