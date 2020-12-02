opengapps-build
===============

A cloud-init script to build opengapps on ubuntu 20.04 and make the package available on http

Usage
-----

Use opengapps-build.sh with whatever cloud service you might use, as a cloud-init/user data script. Make sure you set the hostname of the server to a valid input for opengapps' Makefile, e.g `arm-29-micro`, `arm64-29-full`, etc.

Digitalocean usage
------------------

* Set up [doctl](https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client) with credentials, ensure you can create and delete droplets
* Run ./run-on-do.sh
* The script will provision a droplet that costs $0.06 USD an hour, complete the build if possible, and use wget to download the opengapps zip to your working directory. If there's an error, the droplet may not be destroyed; make sure you delete the droplet if it stalls or is unable to complete the build.
