import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { insertMessageSchema, updateMessageSchema } from "@shared/schema";
import { fromZodError } from "zod-validation-error";

export async function registerRoutes(app: Express): Promise<Server> {
  app.get("/api/health", async (req, res) => {
    try {
      res.json({
        status: "ok",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      res.status(500).json({
        status: "error",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  app.get("/api/messages", async (req, res) => {
    try {
      const messages = await storage.getAllMessages();
      res.json(messages);
    } catch (error) {
      res.status(500).json({
        error: "Failed to fetch messages",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  app.get("/api/messages/:id", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        return res.status(400).json({ error: "Invalid message ID" });
      }

      const message = await storage.getMessage(id);
      if (!message) {
        return res.status(404).json({ error: "Message not found" });
      }

      res.json(message);
    } catch (error) {
      res.status(500).json({
        error: "Failed to fetch message",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  app.post("/api/messages", async (req, res) => {
    try {
      const result = insertMessageSchema.safeParse(req.body);
      
      if (!result.success) {
        const validationError = fromZodError(result.error);
        return res.status(400).json({
          error: "Validation failed",
          message: validationError.message,
        });
      }

      const message = await storage.createMessage(result.data);
      res.status(201).json(message);
    } catch (error) {
      res.status(500).json({
        error: "Failed to create message",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  app.put("/api/messages/:id", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        return res.status(400).json({ error: "Invalid message ID" });
      }

      const result = updateMessageSchema.safeParse(req.body);
      
      if (!result.success) {
        const validationError = fromZodError(result.error);
        return res.status(400).json({
          error: "Validation failed",
          message: validationError.message,
        });
      }

      if (Object.keys(result.data).length === 0) {
        return res.status(400).json({
          error: "Validation failed",
          message: "At least one field must be provided for update",
        });
      }

      const message = await storage.updateMessage(id, result.data);
      if (!message) {
        return res.status(404).json({ error: "Message not found" });
      }

      res.json(message);
    } catch (error) {
      res.status(500).json({
        error: "Failed to update message",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  app.delete("/api/messages/:id", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        return res.status(400).json({ error: "Invalid message ID" });
      }

      const success = await storage.deleteMessage(id);
      if (!success) {
        return res.status(404).json({ error: "Message not found" });
      }

      res.status(204).send();
    } catch (error) {
      res.status(500).json({
        error: "Failed to delete message",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  });

  const httpServer = createServer(app);

  return httpServer;
}
