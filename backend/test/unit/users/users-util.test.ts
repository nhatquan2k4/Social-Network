import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
    ensureValidObjectId,
    normalizePagination,
} from "../../../src/routes/users/shared/users.util.js";

describe("users shared util", () => {
    describe("ensureValidObjectId", () => {
        it("accepts valid Mongo object ids", () => {
            assert.doesNotThrow(() => ensureValidObjectId("507f1f77bcf86cd799439011"));
        });

        it("throws for invalid Mongo object ids", () => {
            assert.throws(() => ensureValidObjectId("not-an-object-id"), /userId khong hop le/);
        });
    });

    describe("normalizePagination", () => {
        it("uses default page and limit when input is missing", () => {
            assert.deepEqual(normalizePagination(), {
                page: 1,
                limit: 20,
                skip: 0,
            });
        });

        it("clamps low page and limit values", () => {
            assert.deepEqual(normalizePagination(-5, -10), {
                page: 1,
                limit: 1,
                skip: 0,
            });
        });

        it("caps limit at the maximum and calculates skip", () => {
            assert.deepEqual(normalizePagination(3, 500), {
                page: 3,
                limit: 50,
                skip: 100,
            });
        });
    });
});
