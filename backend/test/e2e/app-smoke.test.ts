import assert from "node:assert/strict";
import { after, before, describe, it } from "node:test";
import type { Server } from "node:http";
import type { AddressInfo } from "node:net";
import { createApp } from "../../src/app.js";

describe("app smoke end to end", () => {
    let server: Server;
    let baseUrl: string;

    before(async () => {
        const app = createApp();

        server = app.listen(0);

        await new Promise<void>((resolve) => {
            server.once("listening", resolve);
        });

        const address = server.address();
        if (!address || typeof address === "string") {
            throw new Error("Test server did not bind to a TCP port");
        }

        baseUrl = `http://127.0.0.1:${(address as AddressInfo).port}`;
    });

    after(async () => {
        await new Promise<void>((resolve, reject) => {
            server.close((error) => {
                if (error) {
                    reject(error);
                    return;
                }

                resolve();
            });
        });
    });

    it("responds on the health/root route", async () => {
        const response = await fetch(`${baseUrl}/`);
        const body = await response.text();

        assert.equal(response.status, 200);
        assert.equal(body, "Hello World!");
    });

    it("exposes the OpenAPI document", async () => {
        const response = await fetch(`${baseUrl}/api-docs.json`);
        const body = await response.json() as Record<string, unknown>;

        assert.equal(response.status, 200);
        assert.ok(body.openapi || body.swagger);
    });
});
