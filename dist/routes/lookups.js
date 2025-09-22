import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
export const lookupsRouter = Router();
const prisma = new PrismaClient();
// Public: get options by type(s)
// GET /lookups?type=PROJECT&type=PLATFORM
lookupsRouter.get('/', async (req, res) => {
    const types = Array.isArray(req.query.type)
        ? req.query.type
        : req.query.type
            ? [String(req.query.type)]
            : [];
    const where = types.length ? { type: { in: types }, active: true } : { active: true };
    const rows = await prisma.lookup.findMany({ where, orderBy: [{ type: 'asc' }, { order: 'asc' }, { value: 'asc' }] });
    res.json(rows);
});
// Admin: create
lookupsRouter.post('/', async (req, res) => {
    const { type, value, order } = req.body ?? {};
    if (!type || !value)
        return res.status(400).json({ error: 'type and value are required' });
    const row = await prisma.lookup.create({ data: { type, value, order: Number(order) || 0 } });
    res.status(201).json(row);
});
// Admin: update
lookupsRouter.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { type, value, order, active } = req.body ?? {};
    const row = await prisma.lookup.update({ where: { id }, data: { type, value, order, active } });
    res.json(row);
});
// Admin: delete
lookupsRouter.delete('/:id', async (req, res) => {
    const { id } = req.params;
    await prisma.lookup.delete({ where: { id } });
    res.status(204).end();
});
//# sourceMappingURL=lookups.js.map