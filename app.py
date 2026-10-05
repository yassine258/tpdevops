import os
import socket

import redis
from flask import Flask

app = Flask(__name__)
db = redis.Redis(host=os.getenv("REDIS_HOST", "db-service"), port=6379,
                 socket_connect_timeout=2)


@app.route("/")
def index():
    try:
        hits = db.incr("hits")  # opération atomique côté Redis
    except redis.exceptions.RedisError:
        return "Erreur : impossible de joindre db-service\n", 503
    return f"Bonjour ! Cette page a été vue {hits} fois. Je suis le conteneur {socket.gethostname()}\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("APP_PORT", 8787)))