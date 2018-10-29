#! /bin/sh

SLEEP=5

echo "\nRED"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 0 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 10, \"value\": 100 }] }"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 9, \"value\": true }] }"
sleep $SLEEP
echo "\nGREEN"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 120 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
sleep $SLEEP
echo "\nBLUE"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 240 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
sleep $SLEEP
echo "\nYellow"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 60 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
sleep $SLEEP
echo "\nCYAN"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 180 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
sleep $SLEEP
echo "\nPURPLE"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 11, \"value\": 300 },{ \"aid\": 2, \"iid\": 12, \"value\": 100 }] }"
sleep $SLEEP
echo "\nOff"
curl -X PUT http://127.0.01:51826/characteristics --header "Content-Type:Application/json" --header "authorization: 031-45-154" --data "{ \"characteristics\": [{ \"aid\": 2, \"iid\": 9, \"value\": false }] }"
sleep $SLEEP
