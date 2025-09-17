## PMS Backend (Step 1)

Run locally (requires Node.js 18+):

1. Create `.env` with:
   ```
   DATABASE_URL="file:./dev.db"
   PORT=3000
   ```
2. Install deps:
   ```
   npm install
   ```
3. Generate Prisma client and create DB:
   ```
   npx prisma generate
   npx prisma migrate dev --name init
   ```
4. Start dev server:
   ```
   npm run dev
   ```

Health check:
```
GET http://localhost:3000/health
```

Create public request:
```
POST http://localhost:3000/public/requests
Content-Type: application/json

{
  "title": "New feature request",
  "description": "Please add export to CSV",
  "requesterEmail": "user@example.com",
  "requesterName": "Jane Doe",
  "targetSlaHours": 72
}
```

Response:
```
201 { "id": "...", "status": "CREATED" }
```

