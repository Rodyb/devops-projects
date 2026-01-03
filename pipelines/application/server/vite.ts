import express, { type Express } from "express";
import fs from "fs";
import path from "path";
import { createServer as createViteServer, createLogger } from "vite";
import { type Server } from "http";
import viteConfig from "../vite.config";
import { nanoid } from "nanoid";

const viteLogger = createLogger();

export function log(message: string, source = "express") {
  const formattedTime = new Date().toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  });

  console.log(`${formattedTime} [${source}] ${message}`);
}

export async function setupVite(app: Express, server: Server) {
  const serverOptions = {
    middlewareMode: true,
    hmr: { server },
    allowedHosts: true as const,
  };

  const vite = await createViteServer({
    ...viteConfig,
    configFile: false,
    customLogger: {
      ...viteLogger,
      error: (msg, options) => {
        viteLogger.error(msg, options);
        process.exit(1);
      },
    },
    server: serverOptions,
    appType: "custom",
  });

  app.use(vite.middlewares);
  app.use("*", async (req, res, next) => {
    const url = req.originalUrl;

    try {
      const clientTemplate = path.resolve(
        import.meta.dirname,
        "..",
        "client",
        "index.html",
      );

      // always reload the index.html file from disk incase it changes
      let template = await fs.promises.readFile(clientTemplate, "utf-8");
      template = template.replace(
        `src="/src/main.tsx"`,
        `src="/src/main.tsx?v=${nanoid()}"`,
      );
      const page = await vite.transformIndexHtml(url, template);
      res.status(200).set({ "Content-Type": "text/html" }).end(page);
    } catch (e) {
      vite.ssrFixStacktrace(e as Error);
      next(e);
    }
  });
}

export function serveStatic(app: Express) {
  // In production, the bundled server is at dist/index.js
  // and static files are at dist/public
  // Use process.cwd() to get the app root, then resolve to dist/public
  const distPath = path.resolve(process.cwd(), "dist", "public");

  log(`Serving static files from: ${distPath}`);
  
  if (!fs.existsSync(distPath)) {
    const error = `Could not find the build directory: ${distPath}, make sure to build the client first`;
    log(error, "error");
    throw new Error(error);
  }

  // Log what files exist in distPath
  try {
    const files = fs.readdirSync(distPath);
    log(`Found ${files.length} files in dist/public: ${files.slice(0, 5).join(", ")}${files.length > 5 ? "..." : ""}`);
  } catch (e) {
    log(`Could not read dist/public directory: ${e}`, "error");
  }

  const indexPath = path.resolve(distPath, "index.html");
  log(`Index.html path: ${indexPath}, exists: ${fs.existsSync(indexPath)}`);

  // Custom static file middleware that falls through to index.html
  app.use((req, res, next) => {
    // Skip API routes
    if (req.path.startsWith("/api")) {
      return next();
    }

    const filePath = path.join(distPath, req.path === "/" ? "index.html" : req.path);
    
    // Check if file exists
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
      // Serve the file
      return res.sendFile(filePath);
    }
    
    // File doesn't exist, fall through to serve index.html
    next();
  });

  // Catch-all: serve index.html for all non-API routes (SPA routing)
  app.use((req, res) => {
    // Skip API routes
    if (req.path.startsWith("/api")) {
      return res.status(404).json({ error: "Not found" });
    }
    
    // Serve index.html for SPA routing
    log(`Serving index.html for path: ${req.path}`);
    res.sendFile(indexPath, (err) => {
      if (err) {
        log(`Error sending index.html: ${err.message}`, "error");
        if (!res.headersSent) {
          res.status(500).send("Error loading application");
        }
      }
    });
  });
}
