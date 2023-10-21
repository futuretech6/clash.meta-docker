# Clash.Meta Docker

```bash
# run in foreground
docker run --rm -v /path/to/config:/config.yaml -p 7890:7890 -p 9090:9090 futuretech6/clash.meta

# run in background
docker run --name clash.meta -d --restart unless-stopped -v /path/to/config.yaml:/config.yaml -p 7890:7890 -p 9090:9090 futuretech6/clash.meta

# or use docker-compose
cp docker-compose.yaml.demo docker-compose.yaml
docker compose up -d
```
