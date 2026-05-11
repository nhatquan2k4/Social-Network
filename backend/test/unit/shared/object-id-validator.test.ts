import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { isValidObjectId } from "../../../src/shared/validators/object-id.validator.js";

describe("object id validator", () => {
    it("returns true for valid Mongo object id strings", () => {
        assert.equal(isValidObjectId("507f1f77bcf86cd799439011"), true);
    });

    it("returns false for invalid object id strings", () => {
        assert.equal(isValidObjectId("not-an-object-id"), false);
        assert.equal(isValidObjectId("507f1f77bcf86cd79943901"), false);
        assert.equal(isValidObjectId(""), false);
    });
});
