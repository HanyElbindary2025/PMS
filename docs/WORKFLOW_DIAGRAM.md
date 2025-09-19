# PMS Workflow Visual Diagram

## 🔄 Complete Workflow Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ SUBMITTED   │───▶│ ANALYSIS    │───▶│ CONFIRM_DUE │───▶│ DESIGN      │
│ 📝          │    │ 🔍          │    │ ⏰          │    │ 🎨          │
│ 2h SLA      │    │ 24h SLA     │    │ Set SLA     │    │ 48h SLA     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ REJECTED    │    │ ON_HOLD     │    │ ON_HOLD     │    │ ON_HOLD     │
│ ❌          │    │ ⏸️          │    │ ⏸️          │    │ ⏸️          │
│ 24h SLA     │    │ Paused      │    │ Paused      │    │ Paused      │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ DESIGN      │───▶│ DIGITAL_    │───▶│ DEVELOPMENT │───▶│ TESTING     │
│ 🎨          │    │ APPROVAL    │    │ 💻          │    │ 🧪          │
│ 48h SLA     │    │ ✅          │    │ 168h SLA    │    │ 24h SLA     │
└─────────────┘    │ 24h SLA     │    └─────────────┘    └─────────────┘
       │           └─────────────┘           │                   │
       ▼                   │                 ▼                   ▼
┌─────────────┐            │         ┌─────────────┐    ┌─────────────┐
│ ON_HOLD     │            │         │ ON_HOLD     │    │ ON_HOLD     │
│ ⏸️          │            │         │ ⏸️          │    │ ⏸️          │
│ Paused      │            │         │ Paused      │    │ Paused      │
└─────────────┘            │         └─────────────┘    └─────────────┘
                           ▼
                   ┌─────────────┐
                   │ ON_HOLD     │
                   │ ⏸️          │
                   │ Paused      │
                   └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ TESTING     │───▶│ CUSTOMER_   │───▶│ DEPLOYMENT  │───▶│ UAT         │
│ 🧪          │    │ APPROVAL    │    │ 🚀          │    │ 👥          │
│ 24h SLA     │    │ 👥          │    │ 4h SLA      │    │ 48h SLA     │
└─────────────┘    │ 48h SLA     │    └─────────────┘    └─────────────┘
       │           └─────────────┘           │                   │
       ▼                   │                 ▼                   ▼
┌─────────────┐            │         ┌─────────────┐    ┌─────────────┐
│ DEVELOPMENT │            │         │ ON_HOLD     │    │ ON_HOLD     │
│ 💻          │            │         │ ⏸️          │    │ ⏸️          │
│ Back to Dev │            │         │ Paused      │    │ Paused      │
└─────────────┘            │         └─────────────┘    └─────────────┘
                           ▼
                   ┌─────────────┐
                   │ ON_HOLD     │
                   │ ⏸️          │
                   │ Paused      │
                   └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ UAT         │───▶│ VERIFICATION│───▶│ CLOSED      │
│ 👥          │    │ 🔍          │    │ ✅          │
│ 48h SLA     │    │ 8h SLA      │    │ 24h SLA     │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ DEPLOYMENT  │    │ UAT         │    │ Final       │
│ 🚀          │    │ 👥          │    │ State       │
│ Back to Deploy│   │ Back to UAT │    │ No more     │
└─────────────┘    └─────────────┘    │ transitions │
                                      └─────────────┘
```

## 🎯 Role-Based Access Matrix

```
┌─────────────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ Role            │ SUBM    │ ANAL    │ CONFIRM │ DESIGN  │ DIGITAL │ DEV     │ TEST    │ CUSTOM  │ DEPLOY  │ UAT     │ VERIFY  │
├─────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ ADMIN           │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │
│ SERVICE_MANAGER │    ❌   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │    ✅   │
│ TECHNICAL_ANAL  │    ❌   │    ✅   │    ✅   │    ✅   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │
│ SOLUTION_ARCH   │    ❌   │    ❌   │    ❌   │    ✅   │    ✅   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │
│ DEVELOPER       │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ✅   │    ✅   │    ❌   │    ❌   │    ❌   │    ❌   │
│ QA_ENGINEER     │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ✅   │    ❌   │    ❌   │    ❌   │    ❌   │
│ DEVOPS_ENG      │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ✅   │    ✅   │    ✅   │
│ CREATOR         │    ✅   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ❌   │    ✅   │    ❌   │    ✅   │    ✅   │
└─────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘

Legend: ✅ = Can perform actions, ❌ = Read-only access
```

## 📊 SLA Timeline Visualization

```
Phase Timeline with SLA Hours:

SUBMITTED (2h) ──────────────────────────────────────────────────────────────
ANALYSIS (24h) ─────────────────────────────────────────────────────────────
CONFIRM_DUE (Set SLA) ──────────────────────────────────────────────────────
DESIGN (48h) ───────────────────────────────────────────────────────────────
DIGITAL_APPROVAL (24h) ─────────────────────────────────────────────────────
DEVELOPMENT (168h) ─────────────────────────────────────────────────────────
TESTING (24h) ──────────────────────────────────────────────────────────────
CUSTOMER_APPROVAL (48h) ────────────────────────────────────────────────────
DEPLOYMENT (4h) ────────────────────────────────────────────────────────────
UAT (48h) ──────────────────────────────────────────────────────────────────
VERIFICATION (8h) ──────────────────────────────────────────────────────────
CLOSED (24h) ───────────────────────────────────────────────────────────────

Total Maximum SLA: ~400+ hours (16+ days)
```

## 🔄 Transition Rules

### **Allowed Transitions:**
```
SUBMITTED → [ANALYSIS, REJECTED]
ANALYSIS → [CONFIRM_DUE, MEETING_REQUESTED, ON_HOLD, REJECTED]
CONFIRM_DUE → [DESIGN, ON_HOLD, REJECTED]
DESIGN → [DIGITAL_APPROVAL, ON_HOLD, REJECTED]
DIGITAL_APPROVAL → [DEVELOPMENT, ON_HOLD, REJECTED]
DEVELOPMENT → [TESTING, ON_HOLD, CANCELLED]
TESTING → [CUSTOMER_APPROVAL, DEVELOPMENT, ON_HOLD]
CUSTOMER_APPROVAL → [DEPLOYMENT, TESTING, ON_HOLD]
DEPLOYMENT → [UAT, ON_HOLD]
UAT → [VERIFICATION, DEPLOYMENT, ON_HOLD]
VERIFICATION → [CLOSED, UAT, ON_HOLD]
ON_HOLD → [ANALYSIS, CONFIRM_DUE, DESIGN, DIGITAL_APPROVAL, DEVELOPMENT, TESTING, CUSTOMER_APPROVAL, DEPLOYMENT, UAT, CANCELLED]
```

### **Terminal States:**
- **CLOSED** - No further transitions allowed
- **REJECTED** - No further transitions allowed  
- **CANCELLED** - No further transitions allowed

## 🎨 Color Coding

| Phase | Color | Hex Code | Usage |
|-------|-------|----------|-------|
| SUBMITTED | Gray | #9E9E9E | Initial state |
| ANALYSIS | Amber | #FFC107 | Analysis phase |
| CONFIRM_DUE | Blue | #2196F3 | SLA confirmation |
| DESIGN | Blue | #2196F3 | Design phase |
| DIGITAL_APPROVAL | Purple | #9C27B0 | Approval phase |
| DEVELOPMENT | Green | #4CAF50 | Development phase |
| TESTING | Orange | #FF9800 | Testing phase |
| CUSTOMER_APPROVAL | Brown | #795548 | Customer approval |
| DEPLOYMENT | Blue Gray | #607D8B | Deployment phase |
| UAT | Brown | #795548 | User acceptance |
| VERIFICATION | Indigo | #3F51B5 | Verification phase |
| CLOSED | Green | #4CAF50 | Completed state |
| ON_HOLD | Amber | #FFC107 | Paused state |
| REJECTED | Red | #F44336 | Rejected state |
| CANCELLED | Gray | #9E9E9E | Cancelled state |

This workflow design ensures proper governance, role-based access control, and comprehensive tracking throughout the entire project lifecycle.
