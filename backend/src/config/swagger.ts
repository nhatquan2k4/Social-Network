import swaggerJsdoc from "swagger-jsdoc";

const port = process.env.PORT || "3001";
const swaggerServerUrl = process.env.SWAGGER_SERVER_URL || `http://localhost:${port}`;

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
        url: swaggerServerUrl,
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
        MediaItem: {
          type: "object",
          properties: {
            bucket: {
              type: "string",
              description: "Bucket name in MinIO",
            },
            objectKey: {
              type: "string",
              description: "Object path in bucket",
            },
            mimeType: {
              type: "string",
            },
            size: {
              type: "number",
            },
            mediaUrl: {
              type: "string",
              description: "Runtime-composed URL for client consumption",
            },
          },
        },
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
            avatarBucket: {
              type: "string",
              description: "Avatar bucket",
            },
            avatarObjectKey: {
              type: "string",
              description: "Avatar object key",
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
            media: {
              type: "array",
              items: {
                $ref: "#/components/schemas/MediaItem",
              },
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
        DirectMessageRequest: {
          type: "object",
          required: ["recipientId", "conversationId"],
          example: {
            recipientId: "507f1f77bcf86cd799439011",
            conversationId: "507f1f77bcf86cd799439012",
            content: "Hello my friends",
            media: [],
          },
          properties: {
            recipientId: {
              type: "string",
              description: "ID nguoi nhan (phai la ban be)",
              example: "507f1f77bcf86cd799439011",
            },
            conversationId: {
              type: "string",
              description: "ID direct conversation",
              example: "507f1f77bcf86cd799439012",
            },
            content: {
              type: "string",
              description: "Noi dung tin nhan. Co the bo trong neu co media",
              example: "Xin chao ban",
            },
            media: {
              type: "array",
              description: "Danh sach media metadata da upload qua /api/media/upload",
              items: {
                type: "object",
                required: ["bucket", "objectKey", "mimeType", "size"],
                properties: {
                  bucket: {
                    type: "string",
                    example: "social-messages",
                  },
                  objectKey: {
                    type: "string",
                    example: "message/69c.../abc_image.jpg",
                  },
                  mimeType: {
                    type: "string",
                    example: "image/jpeg",
                  },
                  size: {
                    type: "number",
                    example: 124532,
                  },
                },
              },
            },
          },
        },
        GroupMessageRequest: {
          type: "object",
          required: ["conversationId"],
          example: {
            conversationId: "507f1f77bcf86cd799439011",
            content: "Xin chao moi nguoi",
            media: [],
          },
          properties: {
            conversationId: {
              type: "string",
              description: "ID cuoc tro chuyen nhom",
              example: "507f1f77bcf86cd799439011",
            },
            content: {
              type: "string",
              description: "Noi dung tin nhan. Co the bo trong neu co media",
              example: "Xin chao moi nguoi",
            },
            media: {
              type: "array",
              description: "Danh sach media metadata da upload qua /api/media/upload",
              items: {
                type: "object",
                required: ["bucket", "objectKey", "mimeType", "size"],
                properties: {
                  bucket: {
                    type: "string",
                    example: "social-messages",
                  },
                  objectKey: {
                    type: "string",
                    example: "message/69c.../abc_image.jpg",
                  },
                  mimeType: {
                    type: "string",
                    example: "image/jpeg",
                  },
                  size: {
                    type: "number",
                    example: 124532,
                  },
                },
              },
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
            authorId: {
              type: "string",
              description: "Author user ID",
            },
            content: {
              type: "string",
              description: "Post content",
            },
            media: {
              type: "array",
              items: {
                $ref: "#/components/schemas/MediaItem",
              },
            },
            likesCount: {
              type: "number",
            },
            commentsCount: {
              type: "number",
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
        PostComment: {
          type: "object",
          properties: {
            _id: {
              type: "string",
            },
            parentCommentId: {
              type: "string",
              nullable: true,
            },
            authorId: {
              $ref: "#/components/schemas/User",
            },
            content: {
              type: "string",
            },
            createdAt: {
              type: "string",
              format: "date-time",
            },
            updatedAt: {
              type: "string",
              format: "date-time",
            },
            children: {
              type: "array",
              items: {
                $ref: "#/components/schemas/PostComment",
              },
            },
          },
        },
        Notification: {
          type: "object",
          properties: {
            _id: {
              type: "string",
            },
            recipientId: {
              type: "string",
            },
            actorId: {
              $ref: "#/components/schemas/User",
            },
            type: {
              type: "string",
              enum: ["FRIEND_REQUEST", "FRIEND_ACCEPTED", "POST_LIKED", "POST_COMMENTED", "COMMENT_REPLIED"],
            },
            title: {
              type: "string",
            },
            body: {
              type: "string",
            },
            entityType: {
              type: "string",
            },
            entityId: {
              type: "string",
            },
            metadata: {
              type: "object",
              nullable: true,
            },
            isRead: {
              type: "boolean",
            },
            readAt: {
              type: "string",
              format: "date-time",
              nullable: true,
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
              enum: ["direct", "group"],
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
        ConversationDirectCreateRequest: {
          type: "object",
          required: ["type", "recipientId"],
          properties: {
            type: {
              type: "string",
              enum: ["direct"],
              example: "direct",
            },
            recipientId: {
              type: "string",
              description: "ID nguoi nhan trong direct conversation",
              example: "507f1f77bcf86cd799439011",
            },
            name: {
              type: "string",
              description: "Khong bat buoc voi direct conversation",
              nullable: true,
            },
          },
        },
        ConversationGroupCreateRequest: {
          type: "object",
          required: ["type", "name", "memberIds"],
          properties: {
            type: {
              type: "string",
              enum: ["group"],
              example: "group",
            },
            name: {
              type: "string",
              description: "Ten nhom",
              example: "Nhom hoc tap",
            },
            memberIds: {
              type: "array",
              description: "Danh sach userId thanh vien (khong gom user hien tai)",
              items: {
                type: "string",
              },
              example: ["507f1f77bcf86cd799439011", "507f1f77bcf86cd799439012"],
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
