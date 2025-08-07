import axios, { AxiosInstance } from 'axios';
import { spawn, ChildProcess } from 'child_process';
import { z } from 'zod';

// Zod schemas for request validation
const ScanRequestSchema = z.object({
  url: z.string(),
  timeout: z.number().optional().default(180),
  http_timeout: z.number().optional().default(30),
  detailed: z.boolean().optional().default(true),
  format: z.string().optional().default("json"),
  auth_headers: z.record(z.string()).optional(),
});

const BatchScanRequestSchema = z.object({
  urls: z.array(z.string()),
  timeout: z.number().optional().default(180),
  http_timeout: z.number().optional().default(30),
  detailed: z.boolean().optional().default(true),
  format: z.string().optional().default("json"),
  auth_headers: z.record(z.string()).optional(),
});

const ScanConfigRequestSchema = z.object({
  timeout: z.number().optional().default(180),
  http_timeout: z.number().optional().default(30),
  detailed: z.boolean().optional().default(true),
  format: z.string().optional().default("json"),
  auth_headers: z.record(z.string()).optional(),
});

export class RampartsClient {
  private httpClient: AxiosInstance;
  private rampartsProcess: ChildProcess | null = null;
  private serverUrl: string;
  private serverPort: number;

  constructor(port: number = 3001) {
    this.serverPort = port;
    this.serverUrl = `http://localhost:${port}`;
    this.httpClient = axios.create({
      baseURL: this.serverUrl,
      timeout: 60000, // 60 second timeout
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  async ensureServerRunning(): Promise<void> {
    try {
      // Check if server is already running
      await this.httpClient.get('/health');
      return;
    } catch (error) {
      // Server not running, start it
      console.error('🚀 Starting Ramparts server...');
      await this.startRampartsServer();
      
      // Wait for server to be ready
      let retries = 30; // 30 seconds max wait
      while (retries > 0) {
        try {
          await this.httpClient.get('/health');
          console.error('✅ Ramparts server ready');
          return;
        } catch (error) {
          await new Promise(resolve => setTimeout(resolve, 1000));
          retries--;
        }
      }
      
      throw new Error('Failed to start Ramparts server within timeout');
    }
  }

  private async startRampartsServer(): Promise<void> {
    return new Promise((resolve, reject) => {
      // Try to find ramparts binary in PATH or use cargo run
      const rampartsCommand = this.findRampartsCommand();
      
      this.rampartsProcess = spawn(rampartsCommand.command, rampartsCommand.args, {
        stdio: ['ignore', 'pipe', 'pipe'],
        detached: false,
      });

      this.rampartsProcess.stdout?.on('data', (data) => {
        const output = data.toString();
        console.error(`📊 Ramparts: ${output.trim()}`);
        if (output.includes('Starting MCP Scanner Server')) {
          resolve();
        }
      });

      this.rampartsProcess.stderr?.on('data', (data) => {
        const error = data.toString();
        if (!error.includes('Starting') && !error.includes('ready')) {
          console.error(`⚠️ Ramparts: ${error.trim()}`);
        }
      });

      this.rampartsProcess.on('error', (error) => {
        console.error(`❌ Failed to start Ramparts server: ${error}`);
        reject(error);
      });

      this.rampartsProcess.on('exit', (code) => {
        console.error(`🔄 Ramparts server exited with code ${code}`);
        this.rampartsProcess = null;
      });

      // If no stdout confirmation within 10 seconds, assume it started
      setTimeout(() => {
        if (this.rampartsProcess && !this.rampartsProcess.killed) {
          resolve();
        }
      }, 10000);
    });
  }

  private findRampartsCommand(): { command: string; args: string[] } {
    // Try different ways to run ramparts
    const attempts = [
      // Installed via cargo install
      { command: 'ramparts', args: ['server', '--port', this.serverPort.toString(), '--host', '127.0.0.1'] },
      // From source directory (if we're in development)
      { command: 'cargo', args: ['run', '--', 'server', '--port', this.serverPort.toString(), '--host', '127.0.0.1'] },
    ];

    // For now, return the first option. In production, we'd check which is available
    return attempts[0];
  }

  async scan(args: unknown) {
    const request = ScanRequestSchema.parse(args);
    await this.ensureServerRunning();
    
    const response = await this.httpClient.post('/scan', request);
    return response.data;
  }

  async scanConfig(args: unknown) {
    const request = ScanConfigRequestSchema.parse(args);
    await this.ensureServerRunning();
    
    // For scan-config, we need to make multiple scan calls based on discovered configs
    // This is a simplified implementation - in practice, we'd need to discover IDE configs
    const response = await this.httpClient.post('/scan', {
      url: 'scan-config', // Special URL that tells ramparts to scan IDE configs
      ...request,
    });
    return response.data;
  }

  async batchScan(args: unknown) {
    const request = BatchScanRequestSchema.parse(args);
    await this.ensureServerRunning();
    
    const response = await this.httpClient.post('/batch-scan', {
      requests: request.urls.map(url => ({
        url,
        timeout: request.timeout,
        http_timeout: request.http_timeout,
        detailed: request.detailed,
        format: request.format,
        auth_headers: request.auth_headers,
      })),
    });
    return response.data;
  }

  async validateConfig(args: unknown) {
    await this.ensureServerRunning();
    
    const response = await this.httpClient.post('/validate', args);
    return response.data;
  }

  async healthCheck() {
    await this.ensureServerRunning();
    
    const response = await this.httpClient.get('/health');
    return response.data;
  }

  async getCapabilities() {
    await this.ensureServerRunning();
    
    const response = await this.httpClient.get('/protocol');
    return response.data;
  }

  cleanup() {
    if (this.rampartsProcess && !this.rampartsProcess.killed) {
      this.rampartsProcess.kill('SIGTERM');
      this.rampartsProcess = null;
    }
  }
}

// Cleanup on process exit
process.on('SIGINT', () => {
  console.error('🛑 Shutting down Ramparts MCP server...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.error('🛑 Shutting down Ramparts MCP server...');
  process.exit(0);
});