opengapps-build
===============

A cloud-init script to build opengapps on ubuntu 20.04 and make the package available on http

Usage
-----

Use opengapps-build.sh with whatever cloud service you might use, as a cloud-init/user data script. Make sure you set the hostname of the server to a valid input for opengapps' Makefile, e.g `arm-29-micro`, `arm64-29-full`, etc.

Digitalocean usage
------------------

* Set up [doctl](https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client) with credentials, ensure you can create and delete droplets
* Run `./run-on-do.sh [make target]`. If you don't specify a make target (see above), it will automatically select `arm-29-micro`.
* The script will provision a droplet that costs $0.06 USD an hour, complete the build if possible, and use wget to download the opengapps zip to your working directory. If there's an error, the droplet may not be destroyed; make sure you delete the droplet if it stalls or is unable to complete the build.

```
$ ./run-on-do.sh
Running opengapps-build.sh on sgp1:ubuntu-20-04-x64:s-4vcpu-8gb with hostname arm-29-micro
Started at Thu Dec  3 10:28:54 AWST 2020
Provisioning droplet...
++ doctl compute droplet create arm-29-micro --ssh-keys 28633873,28633866 --region sgp1 --size s-4vcpu-8gb --image ubuntu-20-04-x64 --user-data-file opengapps-build.sh --wait --no-header --format PublicIPv4
Droplet at xxx.xx.xxx.xx, waiting for connection...........................
Full log: http://xxx.xx.xxx.xx
Build running........................................................................
--2020-12-03 10:42:18--  http://xxx.xx.xxx.xx/build.zip
Connecting to xxx.xx.xxx.xx:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 371757628 (355M) [application/zip]
Saving to: ‘open_gapps-arm-10.0-micro-20201203-UNOFFICIAL.zip’

open_gapps-arm-10.0-micro- 100%[======================================>] 354.54M  5.19MB/s    in 69s

2020-12-03 10:43:27 (5.12 MB/s) - ‘open_gapps-arm-10.0-micro-20201203-UNOFFICIAL.zip’ saved [371757628/371757628]

Build complete, deleting droplet
++ doctl compute droplet delete -f arm-29-micro
Finished at Thu Dec  3 10:43:30 AWST 2020
Total run time: 876
Total (estimated) cost: USD $0.013518518518518518
```
