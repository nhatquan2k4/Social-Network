import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { normalizePagination } from "../../../src/shared/validators/pagination.validator.js";

describe("pagination validator", () => {
    it("uses default page and limit when input is empty", () => {
        assert.deepEqual(normalizePagination({}), {
            page: 1,
            limit: 20,
        });
    });

    it("clamps invalid page and limit to the minimum", () => {
        assert.deepEqual(normalizePagination({ page: -10, limit: 0 }), {
            page: 1,
            limit: 20,
        });
    });

    it("caps limit at maxLimit", () => {
        assert.deepEqual(normalizePagination({ page: 3, limit: 500, maxLimit: 50 }), {
            page: 3,
            limit: 50,
        });
    });

    it("falls back to defaults for NaN-like values", () => {
        assert.deepEqual(
            normalizePagination({
                page: Number.NaN,
                limit: Number.NaN,
            }),
            {
                page: 1,
                limit: 20,
            },
        );
    });
});
