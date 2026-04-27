# Backend environments

## Development

1. Copy `.env.example` to `.env` and fill local values.
2. Start full local stack:

```bash
docker-compose up --build
```

## Production (VPS)

1. Copy `.env.production.example` to `.env.production`.
2. Replace all placeholder secrets and URLs.
3. Start backend using production compose file:

```bash
docker-compose -f docker-compose.prod.yml up --build -d
```

## Notes

- Production startup fails fast when critical variables are missing.
- `CORS_ORIGIN` must contain your frontend domain(s), comma-separated.
- Keep `.env.production` out of git.
