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
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(morgan('dev'));

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


