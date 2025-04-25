# Monitoring and Health Status Checks 

AI Vault is made up of two essential deployed services. Both have a health check API end point and respond with a 200 to indicate a health running service.  Any other response code is considered unhealthy. 

https://github.com/Bubblr-Inc/ai-vault-aws-installation
 
| Services       | HealthCheck Endpoint| Healthy Response Code|
| --------------- | ------------- |------------- |
|AI Vault|/v1/client/health |200|
|AI Vault Entity | /v1/client/health |200|

Ai Vault Entity is not exposed publicly and is contained in the VPC so it will have to be monitored by a private connection, for an example a monitoring agent installed in a network routable to the internal VPC hosted service.
