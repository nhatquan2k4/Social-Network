import assert from "node:assert/strict";
import crypto from "node:crypto";
import { describe, it } from "node:test";
import {
    ACCESS_TOKEN_TTL,
    REFRESH_TOKEN_TTL,
    generateRefreshToken,
    hashVerificationToken,
} from "../../../src/routes/auth/shared/auth.util.js";

describe("auth shared util", () => {
    it("generates a hex refresh token from 64 random bytes", () => {
        const token = generateRefreshToken();

        assert.match(token, /^[0-9a-f]{128}$/);
    });

    it("hashes verification tokens with sha256", () => {
        const rawToken = "verify-token";
        const expected = crypto.createHash("sha256").update(rawToken).digest("hex");

        assert.equal(hashVerificationToken(rawToken), expected);
        assert.match(hashVerificationToken(rawToken), /^[0-9a-f]{64}$/);
    });

    it("exports token TTL constants", () => {
        assert.equal(ACCESS_TOKEN_TTL, "15m");
        assert.equal(REFRESH_TOKEN_TTL, 14 * 24 * 60 * 60);
    });
});
