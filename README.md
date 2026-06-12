# PulseFlow Health

A clinical dashboard that ingests IoT vitals from hospital devices, stores them in real-time, and displays heart rate, SpO₂, temperature, and blood pressure charts per patient. Critical readings are automatically flagged and anonymized in the background via Sidekiq.

**Stack:** Ruby 4.0.2 · Rails 8.1 · PostgreSQL 15 · React 18 + TypeScript · Sidekiq · Redis

---

## Docker

```bash
cp .env.example .env
docker-compose up --build
```

App runs at http://localhost:3000

---

## Local Development

**First-time setup**
```bash
bundle install && yarn install
cp .env.example .env
RBENV_VERSION=4.0.2 bundle exec rails db:create db:migrate db:seed
```

**Start everything**
```bash
bin/dev
```
Starts Rails (port 3002), esbuild, CSS watcher, and Sidekiq in one command.

App: http://localhost:3002  
Sidekiq dashboard: http://localhost:3002/sidekiq

---

## Tests

```bash
# RSpec (models, services, requests, Capybara UI)
RBENV_VERSION=4.0.2 bundle exec rspec

# Jest (React components)
yarn test
```
