import swaggerJsdoc from "swagger-jsdoc";

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Social Network API",
      version: "1.0.0",
      description: "API documentation for Social Network application",
      contact: {
        name: "API Support",
        email: "support@socialnetwork.com",
      },
    },
    servers: [
      {
        url: "http://localhost:5001",
        description: "Development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
        cookieAuth: {
          type: "apiKey",
          in: "cookie",
          name: "refreshToken",
        },
      },
      schemas: {
        User: {
          type: "object",
          properties: {
            _id: {
              type: "string",
              description: "User ID",
            },
            username: {
              type: "string",
              description: "Unique username",
            },
            email: {
              type: "string",
              format: "email",
              description: "User email",
            },
            displayName: {
              type: "string",
              description: "Display name",
            },
            avatarUrl: {
              type: "string",
              description: "Avatar URL",
            },
            bio: {
              type: "string",
              description: "User biography",
            },
            phone: {
              type: "string",
              description: "Phone number",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
          },
        },
        Message: {
          type: "object",
          properties: {
            _id: {
              type: "string",
              description: "Message ID",
            },
            conversationId: {
              type: "string",
              description: "Conversation ID",
            },
            senderId: {
              type: "string",
              description: "Sender user ID",
            },
            content: {
              type: "string",
              description: "Message content",
            },
            imgUrl: {
              type: "string",
              description: "Image URL",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
          },
        },
        Conversation: {
          type: "object",
          properties: {
            _id: {
              type: "string",
              description: "Conversation ID",
            },
            type: {
              type: "string",
              enum: ["single", "group"],
              description: "Conversation type",
            },
            participants: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  userId: {
                    type: "string",
                    description: "Participant user ID",
                  },
                  joinedAt: {
                    type: "string",
                    format: "date-time",
                  },
                },
              },
            },
            group: {
              type: "object",
              properties: {
                name: {
                  type: "string",
                  description: "Group name",
                },
                createdBy: {
                  type: "string",
                  description: "Creator user ID",
                },
              },
            },
            lastMessage: {
              type: "object",
              properties: {
                _id: {
                  type: "string",
                },
                content: {
                  type: "string",
                },
                senderId: {
                  type: "string",
                },
                createdAt: {
                  type: "string",
                  format: "date-time",
                },
              },
            },
            lastMessageAt: {
              type: "string",
              format: "date-time",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
          },
        },
        FriendRequest: {
          type: "object",
          properties: {
            _id: {
              type: "string",
              description: "Friend request ID",
            },
            from: {
              type: "string",
              description: "Sender user ID",
            },
            to: {
              type: "string",
              description: "Receiver user ID",
            },
            message: {
              type: "string",
              description: "Request message",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
          },
        },
        Post: {
          type: "object",
          properties: {
            _id: {
              type: "string",
              description: "Post ID",
            },
            userId: {
              type: "string",
              description: "Author user ID",
            },
            content: {
              type: "string",
              description: "Post content",
              maxLength: 2000,
            },
            media: {
              type: "array",
              items: {
                type: "string",
              },
              description: "Array of media URLs",
            },
            privacy: {
              type: "string",
              enum: ["public", "friends", "private"],
              description: "Post privacy setting",
            },
            reactions: {
              type: "object",
              additionalProperties: {
                type: "number",
              },
              description: "Reaction counts by type",
            },
            commentsCount: {
              type: "number",
              description: "Number of comments",
            },
            sharesCount: {
              type: "number",
              description: "Number of shares",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
          },
        },
        Error: {
          type: "object",
          properties: {
            message: {
              type: "string",
              description: "Error message",
            },
          },
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ["./src/routes/*.ts", "./src/routes/Post/*.ts", "./src/controller/*.ts", "./src/controller/Post/*.ts"],
};

export const swaggerSpec = swaggerJsdoc(options);
