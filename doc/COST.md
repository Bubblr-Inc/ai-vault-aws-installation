# Cost Estimation

The following chart approximates the pricing per month for running an AI-Vault instance supporting 10-100 users running in the eu-west-1 (Ireland) region. This assumes you are using the recommended AWS components listed below:


| Component       | Pricing |
| --------------- | ------------- |
| ALB Load balancer with TLS | $22   |
| ACM TLS certifcate | $0 |
| DNS Entry | If using Route54 $0.5 |
| Kubernetes Cluster | $60 |
| Node Pool |  $60 PCM |
| PostGres DataBase | $100 PCM |
| _TOTAL_ | 
