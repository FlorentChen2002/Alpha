#!/bin/sh

if [ -z "$1" ]; then
    echo "Il faut mettre stop ou start en argument"
elif [ "$1" = "start" ]; then
    echo "Début du projet opsci"
    cd projet-omega
    docker compose down
    docker compose up -d strapiDB strapi react
    sleep 5
    docker compose up -d zookeeper kafka
    sleep 5
    docker compose up -d kafka-setup #il n'est pas trop utile, il crée juste des topics a l avance
    sleep 5
    docker compose up -d product_producer
    sleep 5
    docker compose up -d product_consumer
    sleep 5
    docker compose up -d event_producer
    sleep 5
    docker compose up -d event_consumer
    sleep 5
    docker compose up -d stock_producer
    sleep 5
    docker compose up -d stock_consumer
    sleep 5
    docker compose up -d mosquitto mqtt-kafka-connector
elif [ "$1" = "stop" ]; then
    cd projet-omega
    echo "Stop du projet"
    docker compose down
else
    echo "Argument non reconnu. Il faut mettre stop ou start en argument"
fi