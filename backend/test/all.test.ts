import { after } from "node:test";
import { stopSharedMongoServer } from "./helpers/e2e.js";

// Import all test suites
import "./e2e/app-smoke.test.js";
import "./e2e/auth.test.js";
import "./e2e/friends.test.js";
import "./e2e/messages.test.js";
import "./e2e/posts.test.js";
import "./e2e/protected-routes.test.js";
import "./e2e/socket.test.js";
import "./e2e/media-notifications.test.js";
import "./e2e/users-admin.test.js";
import "./integration/friends-conversations-notifications.test.js";

after(async () => {
    console.log("Shutting down in-memory MongoDB...");
    await stopSharedMongoServer();
});
