# ClinSight Flutter Backend Integration

## Default Base URL
App is now wired to:
- `https://glitch-backend-tau.vercel.app`

It can be overridden at run time:
```bash
flutter run --dart-define=API_BASE_URL=https://your-domain.com
```

## Integrated Layers
- `lib/services/api_client.dart`: shared GET/POST/multipart client + error handling.
- `lib/services/clinsight_api_service.dart`: wrappers for all backend endpoints:
  - Auth
  - Patients + Dashboard
  - Records compatibility APIs
  - Drug + Pharmacy
  - AI agent endpoints
  - Multipart OCR/intake uploads
  - Blockchain/audit
  - WhatsApp webhook
- `lib/state/app_state.dart`: central provider state for login, patients, dashboard, AI chat.

## Live UI Integration
- Login screen now calls `/api/auth/login`
- Dashboard now fetches live patients and interactions
- Patients screen now fetches/search-filters live data
- Patient detail now fetches `/api/patient/:id` and `/api/patient/:id/brief`
- Assistant chat now calls `/api/agent/query`

## Notes
- Backend is currently tokenless (as per your API notes), so login response is consumed directly.
- Parsers are defensive for varying key names so mobile app won’t break with slight payload differences.
- If your backend returns stricter schemas, model mapping can be tightened further.
