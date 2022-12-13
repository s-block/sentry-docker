echo "Starting Docker..."
nohup dockerd-entrypoint.sh &>/dev/null &
echo "Waiting..."
sleep 20
echo "Running..."
echo "Running docker compose..."
docker-compose up
