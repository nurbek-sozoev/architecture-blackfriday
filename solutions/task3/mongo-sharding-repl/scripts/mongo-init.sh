#!/bin/bash

###
# Останавливаем и удаляем контейнеры
###

echo "Stopping and removing containers"
docker compose down -v

###
# Запускаем контейнеры
###

echo "Starting containers"
docker compose up -d --build
sleep 2

###
# Инициализируем configsvr
###

echo "Initializing configsvr"
docker compose exec -T configsvr mongosh --quiet --eval 'rs.initiate({_id:"configRS",configsvr:true,members:[{_id:0,host:"configsvr:27017"}]})'
docker compose restart mongos
sleep 2

# Инициализируем shard1
###

echo "Initializing shard1 replica set"
docker compose exec -T shard1-1 mongosh --port 27018 --quiet --eval 'rs.initiate({_id:"shardRS1",members:[{_id:0,host:"shard1-1:27018",priority:1},{_id:1,host:"shard1-2:27018",priority:0}]})'
sleep 2

###
# Инициализируем shard2
###

echo "Initializing shard2 replica set"
docker compose exec -T shard2-1 mongosh --port 27019 --quiet --eval 'rs.initiate({_id:"shardRS2",members:[{_id:0,host:"shard2-1:27019",priority:1},{_id:1,host:"shard2-2:27019",priority:0}]})'
sleep 2

###
# Инициализируем mongos
###

echo "Adding shards"
docker compose exec -T mongos mongosh --quiet --eval 'sh.addShard("shardRS1/shard1-1:27018,shard1-2:27018")'
docker compose exec -T mongos mongosh --quiet --eval 'sh.addShard("shardRS2/shard2-1:27019,shard2-2:27019")'

echo "Enabling sharding"
docker compose exec -T mongos mongosh --quiet --eval 'sh.enableSharding("somedb")'

echo "Sharding collection"
docker compose exec -T mongos mongosh --quiet --eval 'sh.shardCollection("somedb.helloDoc", { name: "hashed" })'

###
# Инициализируем бд
###

echo "Inserting data"
docker compose exec -T mongos mongosh <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF
