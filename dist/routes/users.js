import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { z } from 'zod';
const router = Router();
const prisma = new PrismaClient();
// GET /users - Get all users with optional filtering
router.get('/', async (req, res) => {
    try {
        const { role, department, active } = req.query;
        const where = {};
        if (role)
            where.role = role;
        if (department)
            where.department = department;
        if (active !== undefined)
            where.isActive = active === 'true';
        const users = await prisma.user.findMany({
            where,
            orderBy: { name: 'asc' },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                department: true,
                phone: true,
                isActive: true,
                lastLoginAt: true,
                createdAt: true,
                _count: {
                    select: {
                        assignedTickets: true,
                        createdTickets: true,
                    }
                }
            }
        });
        res.json(users);
    }
    catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});
// GET /users/:id - Get specific user
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const user = await prisma.user.findUnique({
            where: { id },
            include: {
                assignedTickets: {
                    select: {
                        id: true,
                        title: true,
                        status: true,
                        priority: true,
                        createdAt: true,
                    },
                    orderBy: { createdAt: 'desc' },
                    take: 10
                },
                createdTickets: {
                    select: {
                        id: true,
                        title: true,
                        status: true,
                        priority: true,
                        createdAt: true,
                    },
                    orderBy: { createdAt: 'desc' },
                    take: 10
                }
            }
        });
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json(user);
    }
    catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ error: 'Failed to fetch user' });
    }
});
// POST /users - Create new user
const createUserSchema = z.object({
    email: z.string().email(),
    name: z.string().min(1),
    role: z.enum(['ADMIN', 'SERVICE_MANAGER', 'SERVICE_DESK', 'TECHNICAL_ANALYST', 'DEVELOPER', 'QA_ENGINEER', 'BUSINESS_ANALYST', 'SOLUTION_ARCHITECT', 'DEVOPS_ENGINEER', 'OPERATIONS_ENGINEER', 'MANAGER', 'CREATOR']),
    department: z.string().optional(),
    phone: z.string().optional(),
});
router.post('/', async (req, res) => {
    try {
        const parse = createUserSchema.safeParse(req.body);
        if (!parse.success) {
            return res.status(400).json({ error: 'Invalid user data', details: parse.error.flatten() });
        }
        const { email, name, role, department, phone } = parse.data;
        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
            where: { email }
        });
        if (existingUser) {
            return res.status(409).json({ error: 'User with this email already exists' });
        }
        const user = await prisma.user.create({
            data: {
                email,
                name,
                role,
                department,
                phone,
            }
        });
        res.status(201).json(user);
    }
    catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Failed to create user' });
    }
});
// PUT /users/:id - Update user
const updateUserSchema = z.object({
    name: z.string().min(1).optional(),
    role: z.enum(['ADMIN', 'SERVICE_MANAGER', 'SERVICE_DESK', 'TECHNICAL_ANALYST', 'DEVELOPER', 'QA_ENGINEER', 'BUSINESS_ANALYST', 'SOLUTION_ARCHITECT', 'DEVOPS_ENGINEER', 'OPERATIONS_ENGINEER', 'MANAGER', 'CREATOR']).optional(),
    department: z.string().optional(),
    phone: z.string().optional(),
    isActive: z.boolean().optional(),
});
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const parse = updateUserSchema.safeParse(req.body);
        if (!parse.success) {
            return res.status(400).json({ error: 'Invalid user data', details: parse.error.flatten() });
        }
        const user = await prisma.user.update({
            where: { id },
            data: parse.data
        });
        res.json(user);
    }
    catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ error: 'Failed to update user' });
    }
});
// DELETE /users/:id - Deactivate user (soft delete)
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const user = await prisma.user.update({
            where: { id },
            data: { isActive: false }
        });
        res.json({ message: 'User deactivated successfully', user });
    }
    catch (error) {
        console.error('Error deactivating user:', error);
        res.status(500).json({ error: 'Failed to deactivate user' });
    }
});
// GET /users/roles - Get available roles
router.get('/roles', async (req, res) => {
    const roles = [
        { value: 'ADMIN', label: 'Administrator', description: 'Full system access' },
        { value: 'SERVICE_MANAGER', label: 'Service Manager', description: 'Manages service delivery' },
        { value: 'SERVICE_DESK', label: 'Service Desk', description: 'First line support' },
        { value: 'TECHNICAL_ANALYST', label: 'Technical Analyst', description: 'Technical analysis and design' },
        { value: 'DEVELOPER', label: 'Developer', description: 'Development and implementation' },
        { value: 'QA_ENGINEER', label: 'QA Engineer', description: 'Quality assurance and testing' },
        { value: 'BUSINESS_ANALYST', label: 'Business Analyst', description: 'Business requirements analysis' },
        { value: 'SOLUTION_ARCHITECT', label: 'Solution Architect', description: 'Solution design and architecture' },
        { value: 'DEVOPS_ENGINEER', label: 'DevOps Engineer', description: 'Deployment and operations' },
        { value: 'OPERATIONS_ENGINEER', label: 'Operations Engineer', description: 'System operations and monitoring' },
        { value: 'MANAGER', label: 'Manager', description: 'Team and project management' },
        { value: 'CREATOR', label: 'Request Creator', description: 'Can create and view own requests' },
    ];
    res.json(roles);
});
export { router as usersRouter };
//# sourceMappingURL=users.js.map