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
  apis: ["./src/routes/*.ts", "./src/controller/*.ts"],
};

export const swaggerSpec = swaggerJsdoc(options);
