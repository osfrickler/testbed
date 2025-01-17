=====
Usage
=====

.. contents::
   :local:

Wireguard
=========

* deployment

  .. code-block:: console

     osism apply wireguard

* client configuration can be found in ``/home/dragon/wireguard-client.conf`` on
  ``testbed-manager``, ``MANAGER_PUBLIC_IP_ADDRESS`` has to be replaced by the
  public address of ``testbed-manager``

Change versions
===============

* Go to ``/opt/configuration`` on the manager node
* Run ``./scripts/set-openstack-version.sh xena`` to set the OpenStack version to ``xena``
* Run ``./scripts/set-ceph-version.sh pacific`` to set the Ceph version to ``pacific``
* Go to ``/home/dragon`` on the manager node
* Run ``ansible-playbook manager-part-2.yml`` to update the manager

This can also be achieved automatically by passing the wanted versions inside the environment
``ceph_version`` and ``openstack_version`` respectively.

.. _Deploy services:

Deploy services
===============

On the testbed, the services can currently be deployed manually. In the future, these manual
steps will be automated by Zuul CI.

* Basic infrastructure services (MariaDB, RabbitMQ, Redis, ...)

  .. code-block:: console

     /opt/configuration/scripts/002-infrastructure-services-basic.sh

* Extended infrastructure services (Patchman, phpMyAdmin, ...)

  .. code-block:: console

     /opt/configuration/scripts/006-infrastructure-services-extended.sh

* Ceph services

  .. code-block:: console

     /opt/configuration/scripts/003-ceph-services.sh

* Basic OpenStack services (Compute, Storage, ...)

  .. code-block:: console

     /opt/configuration/scripts/004-openstack-services-basic.sh

* Extended OpenStack services (Telemetry, Kubernetes, ...)

  .. code-block:: console

     /opt/configuration/scripts/007-openstack-services-extended.sh

* Additional OpenStack services (Rating, Container, ...)

  .. code-block:: console

     /opt/configuration/scripts/008-openstack-services-additional.sh

* Monitoring services (Netdata, Prometheus exporters, ...)

  .. code-block:: console

     /opt/configuration/scripts/005-monitoring-services.sh

Update services
===============

The update of the services is done in the same way as the deployment of the services.
Simply re-run the scripts listed in :ref:`Deploy services`.

Upgrade services
================

For an upgrade, the manager itself is updated first. Set the ``manager_version`` argument in
``environments/manager/configuration.yml`` to the new version and execute ``osism-update-manager``
afterwards.

The upgrade of the services is then done in the same way as the deployment of the services.
Simply re-run the scripts listed in :ref:`Deploy services`.

Purge services
==============

These commands completely remove parts of the environment. This makes reuse possible
without having to create a completely new environment.

OpenStack & infrastructure services
-----------------------------------

.. code-block:: console

   osism-kolla _ purge
   Are you sure you want to purge the kolla environment? [no]: yes
   Are you really sure you want to purge the kolla environment? [no]: ireallyreallymeanit

Ceph
----

.. code-block:: console

   find /opt/configuration -name 'ceph*keyring' -exec rm {} \;
   osism-ceph purge-docker-cluster
   Are you sure you want to purge the cluster? Note that if with_pkg is not set docker
   packages and more will be uninstalled from non-atomic hosts. Do you want to continue?
    [no]: yes

Manager services
----------------

.. code-block:: console

   cd /opt/manager
   docker compose down -v

Some services like phpMyAdmin or OpenStackClient will still run afterwards.

Webinterfaces
=============

.. raw:: html

   <table class="docutils align-default">
      <thead>
         <tr class="row-odd">
            <th class="head">Name</th>
            <th class="head">URL</th>
            <th class="head">Username</th>
            <th class="head">Password</th>
         </tr>
      </thead>
      <tbody>
         <tr class="row-even">
            <td>ARA</td>
            <td><a href="https://ara.testbed.osism.xyz/" target="_blank">https://ara.testbed.osism.xyz/</a></td>
            <td>ara</td>
            <td>password</td>
         </tr>
         <tr class="row-odd">
            <td>Ceph</td>
            <td><a href="https://api-int.testbed.osism.xyz:8140" target="_blank">https://api-int.testbed.osism.xyz:8140</a></td>
            <td>admin</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Flower</td>
            <td><a href="https://flower.testbed.osism.xyz/" target="_blank">https://flower.testbed.osism.xyz/</a></td>
            <td>-</td>
            <td>-</td>
         </tr>
         <tr class="row-odd">
            <td>Grafana</td>
            <td><a href="https://api-int.testbed.osism.xyz:3000" target="_blank">https://api-int.testbed.osism.xyz:3000</a></td>
            <td>admin</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Homer</td>
            <td><a href="https://homer.testbed.osism.xyz" target="_blank">https://homer.testbed.osism.xyz</a></td>
            <td>-</td>
            <td>-</td>
         </tr>
         <tr class="row-even">
            <td>Horizon (via Keystone)</td>
            <td><a href="https://api.testbed.osism.xyz" target="_blank">https://api.testbed.osism.xyz</a></td>
            <td>admin</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Horizon (via Keystone)</td>
            <td><a href="https://api.testbed.osism.xyz" target="_blank">https://api.testbed.osism.xyz</a></td>
            <td>test</td>
            <td>test</td>
         </tr>
         <tr class="row-even">
            <td>Horizon (via Keycloak)</td>
            <td><a href="https://api.testbed.osism.xyz" target="_blank">https://api.testbed.osism.xyz</a></td>
            <td>alice</td>
            <td>password</td>
         </tr>
         <tr class="row-odd">
            <td>Keycloak</td>
            <td><a href="https://keycloak.testbed.osism.xyz" target="_blank">https://keycloak.testbed.osism.xyz</a></td>
            <td>admin</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Kibana</td>
            <td><a href="https://api.testbed.osism.xyz:5601" target="_blank">https://api.testbed.osism.xyz:5601</a></td>
            <td>kibana</td>
            <td>password</td>
         </tr>
         <tr class="row-odd">
            <td>Netbox</td>
            <td><a href="https://netbox.testbed.osism.xyz/" target="_blank">https://netbox.testbed.osism.xyz/</a></td>
            <td>admin</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Netdata</td>
            <td><a href="https://testbed-manager.testbed.osism.xyz:19999" target="_blank">https://testbed-manager.testbed.osism.xyz:19999</a></td>
            <td>-</td>
            <td>-</td>
         </tr>
         <tr class="row-odd">
            <td>Patchman</td>
            <td><a href="https://patchman.testbed.osism.xyz/" target="_blank">https://patchman.testbed.osism.xyz/</a></td>
            <td>patchman</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>Prometheus</td>
            <td><a href="https://api-int.testbed.osism.xyz:9091/" target="_blank">https://api-int.testbed.osism.xyz:9091/</a></td>
            <td>-</td>
            <td>-</td>
         </tr>
         <tr class="row-odd">
            <td>phpMyAdmin</td>
            <td><a href="https://phpmyadmin.testbed.osism.xyz" target="_blank">https://phpmyadmin.testbed.osism.xyz</a></td>
            <td>root</td>
            <td>password</td>
         </tr>
         <tr class="row-even">
            <td>RabbitMQ</td>
            <td><a href="https://api-int.testbed.osism.xyz:15672/" target="_blank">https://api-int.testbed.osism.xyz:15672/</a></td>
            <td>openstack</td>
            <td>BO6yGAAq9eqA7IKqeBdtAEO7aJuNu4zfbhtnRo8Y</td>
         </tr>
      </tbody>
   </table>

.. note::

   To access the webinterfaces, make sure that you have a tunnel up and running for the
   internal networks.

   .. code-block:: console

      make sshuttle ENVIRONMENT=betacloud

.. note::

   If only the identity services were deployed, an error message (``You are not authorized to access this page``)
   appears after logging in to Horizon. This is not critical and results from the absence of the Nova service.

   .. figure:: /images/horizon-login-identity-testbed.png

ARA
---

.. figure:: /images/ara.png

Ceph
----

Deploy `Ceph` first.

.. code-block:: console

   osism apply bootstraph-ceph-dashboard

.. figure:: /images/ceph-dashboard.png

Grafana
-------

.. figure:: /images/grafana.png

Homer
-----

.. code-block:: console

   osism apply homer

.. figure:: /images/homer.png

Keycloak
--------

.. code-block:: console

   osism apply keycloak

.. figure:: /images/keycloak.png

Netbox
------

Netbox is part of the manager and does not need to be deployed individually.

.. figure:: /images/netbox.png

Netdata
-------

.. code-block:: console

   osism apply netdata

.. figure:: /images/netdata.png

Skydive
-------

Deploy `Clustered infrastructure services`, `Infrastructure services`, and
`Basic OpenStack services` first.

.. code-block:: console

   osism apply skydive

The Skydive agent creates a high load on the Open vSwitch services. Therefore
the agent is only started manually when needed.

.. code-block:: console

   osism apply manage-container -e container_action=stop -e container_name=skydive_agent -l skydive-agent

.. figure:: /images/skydive.png

Patchman
--------

.. code-block:: console

   osism apply patchman-client
   osism apply patchman

Every night the package list of the clients is transmitted via cron. Initially
we transfer these lists manually.

.. code-block:: console

   osism-ansible generic all -m command -a patchman-client

After the clients have transferred their package lists for the first time the
database can be built by Patchman.

This takes some time on the first run. Later, this update will be done once a day
during the night via cron.

.. code-block:: console

   patchman-update

The previous steps can also be done with a custom playbook.

.. code-block:: console

   osism apply bootstrap-patchman

.. figure:: /images/patchman.png

Prometheus exporters
--------------------

Deploy `Clustered infrastructure services`, `Infrastructure services`, and
`Basic OpenStack services` first.

.. code-block:: console

   osism apply prometheus

Tools
=====

Rally
-----

.. code-block:: console

   /opt/configuration/contrib/rally/rally.sh
   [...]
   Full duration: 6.30863

   HINTS:
   * To plot HTML graphics with this data, run:
       rally task report 002a01cd-46e7-4976-940f-943586771629 --out output.html

   * To generate a JUnit report, run:
       rally task export 002a01cd-46e7-4976-940f-943586771629 --type junit-xml --to output.xml

   * To get raw JSON output of task results, run:
       rally task report 002a01cd-46e7-4976-940f-943586771629 --json --out output.json

   At least one workload did not pass SLA criteria.

Refstack
--------

.. code-block:: console

   /opt/configuration/contrib/refstack/run.sh
   [...]
   ======
   Totals
   ======
   Ran: 286 tests in 1197.9323 sec.
    - Passed: 284
    - Skipped: 2
    - Expected Fail: 0
    - Unexpected Success: 0
    - Failed: 0
   Sum of execute time for each test: 932.9678 sec.

Check infrastructure services
-----------------------------

The contrib directory contains a script to check the clustered infrastructure services. The
configuration is so that two nodes are already sufficient.

.. code-block:: console

   cd /opt/configuration/contrib
   ./check_infrastructure_services.sh
   Elasticsearch   OK - elasticsearch (kolla_logging) is running. status: green; timed_out: false; number_of_nodes: 2; ...

   MariaDB         OK: number of NODES = 2 (wsrep_cluster_size)

   RabbitMQ        RABBITMQ_CLUSTER OK - nb_running_node OK (2) nb_running_disc_node OK (2) nb_running_ram_node OK (0)

   Redis           TCP OK - 0.002 second response time on 192.168.16.10 port 6379|time=0.001901s;;;0.000000;10.000000

Random data
-----------

The contrib directory contains some scripts to fill the components of the
environment with random data. This is intended to generate a realistic data
load, e.g. for upgrades or scaling tests.

MySQL
~~~~~

After deployment of MariaDB including HAProxy it is possible to create four
test databases each with four tables which are filled with randomly generated
data. The script can be executed multiple times to generate more data.

.. code-block:: console

   cd /opt/configuration/contrib
   ./mysql_random_data_load.sh 100000

Elasticsearch
~~~~~~~~~~~~~

After deployment of Elasticsearch including HAProxy it is possible to create 14 test indices
which are filled with randomly generated data. The script can be executed multiple times to
generate more data.

14 indices are generated because the default retention time for the number of retained
indices is set to 14.

.. code-block:: console

   cd /opt/configuration/contrib
   ./elasticsearch_random_data_load.sh 100000

Recipes
=======

This section describes how individual parts of the testbed can be deployed.

* Ceph

  .. code-block:: console

     osism apply ceph-mons
     osism apply ceph-mgrs
     osism apply ceph-osds
     osism apply ceph-mdss
     osism apply ceph-crash
     osism apply ceph-rgws
     osism apply copy-ceph-keys
     osism apply cephclient

* Clustered infrastructure services

  .. code-block:: console

     osism apply common
     osism apply loadbalancer
     osism apply elasticsearch
     osism apply rabbitmq
     osism apply mariadb

* Infrastructure services (also deploy `Clustered infrastructure services`)

  .. code-block:: console

     osism apply openvswitch
     osism apply ovn
     osism apply memcached
     osism apply kibana


* Basic OpenStack services (also deploy `Infrastructure services`,
  `Clustered infrastructure services`, and `Ceph`)

  .. code-block:: console

     osism apply keystone
     osism apply horizon
     osism apply placement
     osism apply glance
     osism apply cinder
     osism apply neutron
     osism apply nova
     osism apply openstackclient
     osism apply bootstrap-basic

* Additional OpenStack services (also deploy `Basic OpenStack services` and all requirements)

  .. code-block:: console

     osism apply heat
     osism apply gnocchi
     osism apply ceilometer
     osism apply aodh
     osism apply barbican
     osism apply designate
     osism apply octavia
