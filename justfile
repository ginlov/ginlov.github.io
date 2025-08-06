stop:
  docker compose down || true

dev: stop
  docker compose up -d   
  docker compose logs -f jekyll
