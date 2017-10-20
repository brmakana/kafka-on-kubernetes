# Currently statefulsets don't have an actual 'name' label, so we can't use that for
# Service selectors. Instead, use this hack
#!/bin/sh
kubectl label --overwrite pods kafka-0 brokerId="0"
kubectl label --overwrite pods kafka-1 brokerId="1"
kubectl label --overwrite pods kafka-2 brokerId="2"
kubectl label --overwrite pods kafka-3 brokerId="3"
kubectl label --overwrite pods kafka-4 brokerId="4"