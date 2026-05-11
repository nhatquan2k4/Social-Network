import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
    sendCreated,
    sendError,
    sendSuccess,
} from "../../../src/shared/http/response.js";

const createResponse = () => {
    const response = {
        statusCode: undefined as number | undefined,
        body: undefined as unknown,
        status(code: number) {
            this.statusCode = code;
            return this;
        },
        json(payload: unknown) {
            this.body = payload;
            return this;
        },
    };

    return response;
};

describe("http response helpers", () => {
    it("sends success responses with data and default status", () => {
        const res = createResponse();
        const result = sendSuccess(res as any, { id: "1" });

        assert.equal(result, res);
        assert.equal(res.statusCode, 200);
        assert.deepEqual(res.body, { data: { id: "1" } });
    });

    it("sends success responses with custom status", () => {
        const res = createResponse();

        sendSuccess(res as any, { ok: true }, 202);

        assert.equal(res.statusCode, 202);
        assert.deepEqual(res.body, { data: { ok: true } });
    });

    it("sends created responses with message and data", () => {
        const res = createResponse();

        sendCreated(res as any, { id: "1" }, "User created");

        assert.equal(res.statusCode, 201);
        assert.deepEqual(res.body, {
            message: "User created",
            data: { id: "1" },
        });
    });

    it("sends error responses with message and status", () => {
        const res = createResponse();

        sendError(res as any, "Invalid request", 422);

        assert.equal(res.statusCode, 422);
        assert.deepEqual(res.body, { message: "Invalid request" });
    });
});
