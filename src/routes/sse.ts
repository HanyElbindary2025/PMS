import { Router, Request, Response } from 'express';
import { bus } from '../events.js';

export const sseRouter = Router();

sseRouter.get('/stream', (req: Request, res: Response) => {
	res.setHeader('Content-Type', 'text/event-stream');
	res.setHeader('Cache-Control', 'no-cache');
	res.setHeader('Connection', 'keep-alive');
	res.flushHeaders?.();

	const write = (data: unknown) => {
		res.write(`data: ${JSON.stringify(data)}\n\n`);
	};

	const onEvent = (evt: unknown) => write(evt);
	bus.on('event', onEvent);

	// heartbeat
	const interval = setInterval(() => res.write(': keep-alive\n\n'), 15000);

	req.on('close', () => {
		clearInterval(interval);
		bus.off('event', onEvent);
	});
});


