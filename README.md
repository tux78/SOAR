# Security Orchestration, Automation and Response 
This repository provides a docker-based installation of MISP and intelMQ. Using this, a fully operational installation can be set up within just a few steps

## Why SOAR?
SOAR is actually mostly process based, and includes the definition, setup, deployment, management and monitoring of managed networks. This is mostly process based, and can typically be automated to a certain extend. MISP and intelMQ provide a very powerful extension to support SOAR processes, especially as manual tasks can be fully automated as long as the connected systems provide a scriptable interface (webUI, DB, API etc).

## Use Cases or Playbooks
### Collecting threat intelligence feeds
MISP supports the process of collecting (and consolidating) threat intelligence feeds, which may be ingested from a number of sources. This can be single fields (such as CnC server IP addresses, domains, hashes of malicious files), but can also comprise sophistocated information around campaigns (including all previous information in a single record).
By applying Tags this information can be preprared for later processing by subsequent enforcement points, such as firewalls or proxies. INtelMQ collects this information from MISP, and applies it to those appliances.

### Boarding SIEM-relevant devices
Provisioning new devices, such as Windows Domain Controllers, is typically documented within a CMDB, including the provisioning process itself. Since those devices may be relevant to a deployed SIEM system as well, they have to be properly boarded.
IntelMQ supports this by connecting to the CMDB, processing the relevant information, and automatically boarding newly provisioned devices into the SIEM installation.

### EDR tasks
An EDR task may include searching for suspicious files within the deployed environment, and take appropriate action in case of a finding.
IntelMQ can collect hash information from MISP, execute a McAfee Active Response Query, and take action based on any finding such as blocking suspicious IP address on a firewall/proxy, or add them to SIEM watch lists

# Installation
## Create working directory
As a first step it is recommended to create a working directory
```
# mkdir SOAR
# cd SOAR
```

## Clone repository
Cloning the repository is done by running the following command
```
# git clone https://github.com/tux78/SOAR.git
```

## Execute setup routine
The actual setup is initiated by executing the setup routine
```
# ./setup.sh
```

The following setup will ask some questions:
- Install MISP
- Install intelMQ
- Integrate intelMQ with ePO (requires ePO IP, username and password)

Please note that especially the MISP setup requires some time. Depending on resources this can take up to 1/2 hour!

Integrating intelMQ with ePO actually generates a CSR, which is automatically forwarded to and signed by the McAfee ePO server. Once finished, all necessary files to operate openDXL are located in the following location within the docker container:
```
# ls -l /etc/intelmq/openDXL
```
This folder especially holds the client.config file, which has to be addressed when configuring the openDXL bot.

If McAfee ePO integration has been missed during setup, it can be executed at a later stage as well using below command:
```
# docker-compose exec intelmq\
        /usr/local/bin/dxlclient\
        provisionconfig /etc/intelmq/openDXL EPO_IP HOST_IP -t EPO_PORT -u EPO_ADMIN -p EPO_PW
```
Please replace the following variables with the respective values:
- EPO_IP: ip address of McAfee ePO server
- HOST_IP: IP address of docker host
- EPO_PORT: webUI port McAfee ePO server is listening on (Default: 8443)
- EPO_ADMIN/EPO_PW: credentials of admin user entitled to sign certificates

# Operations

## intelMQ
The intelMQ webUI is accessible here:

https://[docker IP]:8443/

The default credentials are as follows:
- username: intelmqadmin
- password: intelmqadmin

The password can be changed by editing the following file:

```
# vi /etc/intelmq/intelmq-manager.htusers
```

## MISP
The MIPS webUI is accessible here:

https://[docker IP]/

The default credentials are as follows:
- username: admin@admin.test
- password: admin

You are required to change the password after first login. Please note that the new password has to satisfy various requirements:
- min 12 characters
- min 1 lowercase
- min 1 uppercase
- min 1 special character

## intelMQ Development
Development of additinal intelMQ Bots takes place in the following directory on the docker host itself:
```
# cd ./dev_intelmq/intelmq/bots
```
Bots are located in the corresponding directories:
- collectors
- parsers
- experts
- outputs

Keep in mind that additional (new) bots have to be added to the following file as well:
```
# vi ./dev_intelmq/intelmq/bots/BOTS
```
In order to apply any changes to the running environment, the following command can be executed:
```
# ./docker-compose exec intelmq /update_dev.sh
```
For additional information, please visit the intelMQ development guide:

https://intelmq.readthedocs.io/en/latest/Developers-Guide/
