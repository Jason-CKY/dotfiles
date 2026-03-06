import type { Plugin } from "@opencode-ai/plugin";
import { existsSync, readFileSync } from "fs";
import { join } from "path";

/**
 * OpenCode Plugin: Hybrid Local/Remote MCP Discovery
 * Scans current directory for .mcp.json and converts Claude-style 
 * configs into OpenCode's native schema.
 */
export const LocalMCPDiscovery: Plugin = async ({ directory }) => {
  console.log(`[mcp-loader] Starting MCP discovery in ${directory}`);
  
  const mcpFilePath = join(directory, ".mcp.json");

  if (!existsSync(mcpFilePath)) {
    console.log(`[mcp-loader] ${mcpFilePath} does not exist`);
    return { config: async (config) => config };
  }

  console.log(`[mcp-loader] Found ${mcpFilePath}`);
  
  try {
    const fileContent = readFileSync(mcpFilePath, "utf-8");
    const data = JSON.parse(fileContent);

    // Claude usually nests under "mcpServers"
    const servers = data.mcpServers || data;
    const opencodeMcpConfigs: Record<string, any> = {};

    for (const [name, config] of Object.entries(servers)) {
      const c = config as any;

      // 1. Check if it's a Remote MCP (SSE)
      if (c.url) {
        opencodeMcpConfigs[name] = {
          type: "remote",
          url: c.url,
          enabled: true,
          // Optional: pass through headers if defined in your .mcp.json
          headers: c.headers || {}
        };
      } 
      // 2. Check if it's a Local MCP (Command-line)
      else if (c.command) {
        opencodeMcpConfigs[name] = {
          type: "local",
          // OpenCode merges command and args into a single array
          command: [c.command, ...(c.args || [])],
          env: c.env || {},
          enabled: true
        };
      }
    }

    const names = Object.keys(opencodeMcpConfigs);
    if (names.length > 0) {
      console.log(`[mcp-loader] Imported ${names.length} MCP servers: ${names.join(", ")}`);
    }

    // Return the config hook to add MCP servers to OpenCode's configuration
    return {
      config: async (config: any) => {
        // Initialize mcp section if it doesn't exist
        if (!config.mcp) {
          config.mcp = {};
        }
        
        // Merge discovered MCP servers with existing config
        config.mcp = {
          ...config.mcp,
          ...opencodeMcpConfigs
        };
        
        console.log(`[mcp-loader] Config updated with ${names.length} MCP servers`);
        return config;
      }
    };

  } catch (error) {
    console.error(`[mcp-loader] Failed to load .mcp.json: ${String(error)}`);
    return { config: async (config) => config };
  }
};

export default LocalMCPDiscovery;
