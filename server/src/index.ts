import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const SWITCH_API_KEY = process.env.SWITCH_API_KEY || 'sk-82bceb8e214b56c34ca35838140024ae4340e36dcfb5afe4';
const SWITCH_API_BASE = 'https://api.ecomagent.in/v1';

// Security & Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

// Validation Schemas
const ChatMessageSchema = z.object({
  role: z.enum(['user', 'assistant', 'system']),
  content: z.string().min(1),
});

const ChatCompletionSchema = z.object({
  model: z.string(),
  messages: z.array(ChatMessageSchema),
  temperature: z.number().optional().default(0.7),
  max_tokens: z.number().optional().default(2048),
  stream: z.boolean().optional().default(false),
});

// Routes
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'online',
    service: 'Switch Proxy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.post('/v1/chat/completions', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = ChatCompletionSchema.parse(req.body);
    
    console.log(`[Switch] Proxying request for model: ${body.model}`);
    
    const response = await fetch(`${SWITCH_API_BASE}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SWITCH_API_KEY}`
      },
      body: JSON.stringify(body)
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`[Switch] API Error: ${response.status} - ${errorText}`);
      return res.status(response.status).json({
        error: {
          message: 'Upstream API error',
          status: response.status,
          details: errorText
        }
      });
    }

    const data = await response.json();
    res.json(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Validation failed', details: error.errors });
    }
    next(error);
  }
});

// Error Handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  console.error('[Switch] Server Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : err.message
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Switch Proxy Server running on http://localhost:${PORT}`);
  console.log(`🔗 Proxying to: ${SWITCH_API_BASE}`);
});
