import 'dotenv/config';
import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { publicRouter } from './routes/public.js';
import { ticketsRouter } from './routes/tickets.js';
import { sseRouter } from './routes/sse.js';
import { startSlaTicker } from './sla.js';
import { lookupsRouter } from './routes/lookups.js';
import { attachmentsRouter } from './routes/attachments.js';
import { usersRouter } from './routes/users.js';

const app = express();

app.use(helmet());

// CORS configuration
const defaultOrigins = ['https://pms-frontend-09gz.onrender.com'];
const allowedOrigins = (process.env.CORS_ORIGINS || defaultOrigins.join(','))
  .split(',')
  .map((o) => o.trim())
  .filter((o) => o.length > 0);

const corsOptions: cors.CorsOptions = {
  origin: (origin, callback) => {
    if (!origin) {
      // allow non-browser or same-origin requests
      return callback(null, true);
    }
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['Content-Disposition'],
  credentials: true,
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

// Lightweight request logger to help diagnose CORS/origin and URL issues
app.use((req: Request, _res: Response, next: NextFunction) => {
  // eslint-disable-next-line no-console
  console.log(`[req] ${req.method} ${req.originalUrl} origin=${req.headers.origin || 'n/a'}`);
  next();
});

app.get('/', (_req: Request, res: Response) => {
  res.json({ 
    message: 'PMS Backend API is running!', 
    service: 'pms-backend', 
    version: '0.1.0',
    endpoints: {
      health: '/health',
      tickets: '/tickets',
      users: '/users',
      lookups: '/lookups',
      attachments: '/attachments',
      events: '/events',
      public: '/public'
    }
  });
});

app.get('/health', (_req: Request, res: Response) => {
  res.json({ ok: true, service: 'pms-backend', version: '0.1.0' });
});

// Expose effective CORS allowlist for diagnostics
app.get('/version', (_req: Request, res: Response) => {
  res.json({
    service: 'pms-backend',
    version: '0.1.0',
    allowedOrigins,
    nodeEnv: process.env.NODE_ENV || 'unknown',
  });
});

app.use('/public', publicRouter);
app.use('/tickets', ticketsRouter);
app.use('/events', sseRouter);
app.use('/lookups', lookupsRouter);
app.use('/attachments', attachmentsRouter);
app.use('/users', usersRouter);

// Global error handler
app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
  // eslint-disable-next-line no-console
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal Server Error' });
});

const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, '0.0.0.0', () => {
  // eslint-disable-next-line no-console
  console.log(`Server listening on http://0.0.0.0:${PORT}`);
});

startSlaTicker();


