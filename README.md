# PulseFlow Health

Real-time clinical health telemetry dashboard for IoT vitals streaming.

**Stack:** Ruby 4.0.2 · Rails 8.1 · PostgreSQL 15 · React 18 + TypeScript · Sidekiq · Redis

## Quick Start (Docker)

```bash
cp .env.example .env
docker-compose up --build
```

App runs at `http://localhost:3000`

## Local Development

**Requirements:** Ruby 4.0.2, Node 20+, PostgreSQL 15, Redis 7

### First-time setup

```bash
bundle install
yarn install
cp .env.example .env
RBENV_VERSION=4.0.2 bundle exec rails db:create db:migrate db:seed
```

### Starting the servers

**Option A — one command (recommended)**

```bash
bin/dev
```

This starts all 4 processes via foreman:
- `web` — Rails server on http://localhost:3002
- `js` — esbuild watching `app/javascript/`
- `css` — Sass + PostCSS watching `app/assets/stylesheets/`
- `sidekiq` — background job worker

**Option B — separate terminals**

```bash
# Terminal 1 — Rails
RBENV_VERSION=4.0.2 bundle exec rails server -p 3002

# Terminal 2 — JS watcher
yarn build --watch

# Terminal 3 — CSS watcher
yarn watch:css

# Terminal 4 — Sidekiq
RBENV_VERSION=4.0.2 bundle exec sidekiq -C config/sidekiq.yml
```

App: http://localhost:3002  
Sidekiq dashboard: http://localhost:3002/sidekiq

## Running Tests

```bash
# Ruby / RSpec
bundle exec rspec

# JavaScript / Jest
npm test
```

## Environment Variables

See `.env.example` for all required variables.

## Architecture

```
app/
├── models/           # Patient, VitalReading (UUID PKs, JSONB)
├── services/
│   └── vitals/       # IngestionService, EhrClient
├── jobs/
│   └── vitals/       # AnonymizeAndArchiveJob (Sidekiq)
├── controllers/
│   └── api/v1/       # JSON API endpoints
├── serializers/      # Blueprinter serializers
└── views/api/v1/     # Jbuilder templates

app/javascript/
├── components/       # React + TypeScript components
│   ├── Dashboard/
│   ├── PatientList/
│   └── VitalChart/
└── __tests__/        # Jest tests
```
