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

```bash
bundle install
npm install
cp .env.example .env
bundle exec rails db:create db:migrate db:seed
bin/dev          # starts Rails + esbuild + CSS watcher
```

Sidekiq in a separate terminal:
```bash
bundle exec sidekiq
```

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
