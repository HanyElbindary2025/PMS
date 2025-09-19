import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { v4 as uuidv4 } from 'uuid';

export const attachmentsRouter = Router();
const prisma = new PrismaClient();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Allow common document and image types
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'text/csv',
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
      'application/zip',
      'application/x-rar-compressed',
      'application/json',
      'application/xml',
      'text/xml'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('File type not allowed'), false);
    }
  }
});

// Upload attachment
attachmentsRouter.post('/upload', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const { ticketId, stageId, category, description } = req.body;
    
    if (!ticketId) {
      return res.status(400).json({ error: 'Ticket ID is required' });
    }

    // Verify ticket exists
    const ticket = await prisma.ticket.findUnique({
      where: { id: ticketId }
    });

    if (!ticket) {
      return res.status(404).json({ error: 'Ticket not found' });
    }

    // Create attachment record
    const attachment = await prisma.attachment.create({
      data: {
        ticketId,
        stageId: stageId || null,
        fileName: req.file.filename,
        originalName: req.file.originalname,
        fileSize: req.file.size,
        mimeType: req.file.mimetype,
        filePath: req.file.path,
        category: category || null,
        description: description || null,
        uploadedBy: 'system', // TODO: Get from auth
      }
    });

    res.status(201).json({
      id: attachment.id,
      fileName: attachment.fileName,
      originalName: attachment.originalName,
      fileSize: attachment.fileSize,
      mimeType: attachment.mimeType,
      category: attachment.category,
      description: attachment.description,
      uploadedAt: attachment.uploadedAt
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'Upload failed' });
  }
});

// Get attachments for a ticket
attachmentsRouter.get('/ticket/:ticketId', async (req: Request, res: Response) => {
  try {
    const { ticketId } = req.params;
    const { stageId } = req.query;

    const where: any = { ticketId };
    if (stageId) {
      where.stageId = stageId;
    }

    const attachments = await prisma.attachment.findMany({
      where,
      orderBy: { uploadedAt: 'desc' }
    });

    res.json(attachments.map(att => ({
      id: att.id,
      originalName: att.originalName,
      fileSize: att.fileSize,
      mimeType: att.mimeType,
      category: att.category,
      description: att.description,
      uploadedBy: att.uploadedBy,
      uploadedAt: att.uploadedAt
    })));
  } catch (error) {
    console.error('Get attachments error:', error);
    res.status(500).json({ error: 'Failed to get attachments' });
  }
});

// Download attachment
attachmentsRouter.get('/download/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const attachment = await prisma.attachment.findUnique({
      where: { id }
    });

    if (!attachment) {
      return res.status(404).json({ error: 'Attachment not found' });
    }

    // Check if file exists
    if (!fs.existsSync(attachment.filePath)) {
      return res.status(404).json({ error: 'File not found on disk' });
    }

    res.setHeader('Content-Disposition', `attachment; filename="${attachment.originalName}"`);
    res.setHeader('Content-Type', attachment.mimeType);
    res.setHeader('Content-Length', attachment.fileSize);

    const fileStream = fs.createReadStream(attachment.filePath);
    fileStream.pipe(res);
  } catch (error) {
    console.error('Download error:', error);
    res.status(500).json({ error: 'Download failed' });
  }
});

// Delete attachment
attachmentsRouter.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const attachment = await prisma.attachment.findUnique({
      where: { id }
    });

    if (!attachment) {
      return res.status(404).json({ error: 'Attachment not found' });
    }

    // Delete file from disk
    if (fs.existsSync(attachment.filePath)) {
      fs.unlinkSync(attachment.filePath);
    }

    // Delete from database
    await prisma.attachment.delete({
      where: { id }
    });

    res.json({ message: 'Attachment deleted successfully' });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ error: 'Delete failed' });
  }
});

// Get attachment categories
attachmentsRouter.get('/categories', (req: Request, res: Response) => {
  const categories = [
    'Initial Requirements',
    'Screenshots',
    'Documents',
    'Categorization Rationale',
    'Service Documentation',
    'Impact Analysis',
    'Risk Assessment',
    'Business Case',
    'Technical Documentation',
    'Analysis Reports',
    'Feasibility Study',
    'Design Documents',
    'Architecture Diagrams',
    'Mockups',
    'Wireframes',
    'Approval Documents',
    'Sign-offs',
    'Stakeholder Feedback',
    'Code',
    'Test Cases',
    'Progress Reports',
    'Documentation',
    'Test Reports',
    'Bug Reports',
    'Test Data',
    'Performance Reports',
    'UAT Reports',
    'User Feedback',
    'Acceptance Criteria',
    'Deployment Scripts',
    'Monitoring Reports',
    'Go-Live Checklist',
    'Verification Reports',
    'Monitoring Data',
    'Performance Metrics',
    'Final Reports',
    'Lessons Learned',
    'Hold Justification',
    'Dependency Documentation',
    'Issue Reports',
    'Rejection Documentation',
    'Alternatives',
    'Appeal Process',
    'Cancellation Documentation',
    'Impact Assessment'
  ];

  res.json(categories);
});
