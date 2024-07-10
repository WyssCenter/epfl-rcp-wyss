

EPFL RCP
********


This repository is an introduction on how to use EPFL RCP cluster.

It comes on top of their `own documentation <https://wiki.rcp.epfl.ch/en/home/CaaS/Quick_Start>`_ and provides 
some useful commands and tips to use the cluster for the NeuroAI group of the Wyss Center for Neuro and BioEngineering.

It does include common configurations such as executing a script pulled from a private repository, starting a Jupyter notebook server,
and accessing the scratch directory.

.. raw:: html

    <embed>
        <p align="center">
        <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./logos/wyss-center-full-inverse.png">
        <img alt="Wyss Center logo" src="./logos/wyss-center-full.png" width="70%">
        </picture>
        </p>
    </embed>


Prerequisites
-------------

Follow the instructions in the section ``Run:AI CLI`` of the `RCP documentation <https://wiki.rcp.epfl.ch/en/home/CaaS/Quick_Start#runai-cli>`_.
You can skip this step if you have ``runai`` and ``kubectl`` running on your machine.

.. note::

    ``-g 1`` is used to request a GPU node. It's always used in the command examples below but can be omitted if you don't
    need a GPU.

    ``--cpu 12`` is used to request 24 CPUs. It's always used in the command examples below but can be omitted if you don't
    need that many CPUs.

    ``--memory 64G`` is used to request 64Gi of memory. It's always used in the command examples below but can be omitted
    if you don't need that much memory.


Create ssh secret for kubernetes
--------------------------------

To create a secret with the SSH key to pull the private repositories, follow the steps below:

1. Create ssh key pair.
2. Add this key to your github account.
3. Create the secret in kubernetes:

    .. code-block:: bash

        kubectl create secret generic ssh-key-secret --from-file=~/.ssh/<your_private_key>

4. Add the secret to the pod by adding the following to any ``runai submit`` command:

    .. code-block:: bash

        -e SSH_PRIVATE_KEY=SECRET:ssh-key-secret,<your_private_key>


Common ``run submit`` arguments: overview
------------------------------------------

Whatever mode you use (interactive or train), you need to provide the following environment variables:

- ``-e SSH_PRIVATE_KEY=SECRET:ssh-key-secret,<your_private_key>``: the SSH key to pull the private repositories. See the
  section above to create the secret.
- ``-e USER=<username>``: the user to use in the container. Example: ``klee``. This is also required to automatically pull
  the repositories.
- ``-e GIT_BRANCH_WYSS_DS=<branch>`` *(optional)*: the branch to clone for the ``wyss_ds`` repository. The default is ``dev``.
- ``-e GIT_BRANCH_SYN_DECODER=<branch>`` *(optional)*: the branch to clone for the ``syn_decoder`` repository. The default is ``dev``.
- ``-e EXTRA_DEPS=<dependencies>`` *(optional)*: extra dependencies to install in the container through ``pip`` before running the script
  or starting the Jupyter notebook. Example: ``torchvision==0.18.1 matplotlib``


Interactive session
-------------------

Interactive sessions cannot be preempted but last for maximum 12 hours. If you need more time, you need to submit a job in train mode.


bash
^^^^

To start an interactive session with the image, you can use the following command:

.. code-block:: bash
    
    runai submit -i registry.rcp.epfl.ch/rcp-runai-upcourtine-klee/wyss_nvidia_pytorch_deps:latest \
        -e USER='klee' -e SSH_PRIVATE_KEY=SECRET:ssh-key-secret,id_ed25519_runai \
        --pvc runai-upcourtine-klee-scratch:/home/klee/nas:rw --interactive --attach -g 1 --cpu 12 --memory 64G

This command will start an interactive session with the image and attach the current terminal to the session. The session will be
executed on a GPU node.


Jupyter notebook
^^^^^^^^^^^^^^^^

To start a Jupyter notebook server, you need to forward the port used by jupyter to your local machine.
To do this, you need to add the following to the ``runai submit`` command:

- ``-e JUPYTER_PORT=<port>`` *(optional)*: the port used by Jupyter notebook in the container. The default is ``8889``.
- ``--service-type portforward --port <local machine port>:<container port>``: to forward the port to your local machine

The whole command is:

.. code-block:: bash

    runai submit -i registry.rcp.epfl.ch/rcp-runai-upcourtine-klee/wyss_nvidia_pytorch_deps:latest --attach \
        -e SSH_PRIVATE_KEY=SECRET:ssh-key-secret,id_ed25519_runai -e USER='klee' \
        -e JUPYTER_PORT=8889 --service-type portforward --port 8888:8889 \
        --pvc runai-upcourtine-klee-scratch:/home/klee/nas:rw --interactive -g 1 --cpu 12 --memory 64G

And in a new terminal:

.. code-block:: bash

    runai bash job-name
    ./run_jupyter.sh

.. note::

    You **must** see something like this in the logs:

    ::

        Open access point(s) to service from localhost:8888
        Forwarding from 127.0.0.1:8888 -> 8889
        Forwarding from [::1]:8888 -> 8889

    If not, try to change the port to 8889 in the command above.


You can now access the Jupyter notebook server by opening browser on your local machine and navigating to ``http://localhost:8888``.
Use the token provided in the logs to log in: ``?token=...``


Train mode
----------

To submit a job in train mode, you need to provide a script to run in the container. The script is passed as an argument
when submitting the job. You must also provide environment variables to the container:

- ``-e SCRIPT_PATH=<relative-path-to-script>``: the path to the script to run in the container **relative to the ``syn_decoder`` repository root**

Example:

.. code-block:: bash

    runai submit -i registry.rcp.epfl.ch/rcp-runai-upcourtine-klee/wyss_nvidia_pytorch_deps:latest --attach \
        -e SSH_PRIVATE_KEY=SECRET:ssh-key-secret,id_ed25519_runai -e USER='klee' \
        -e SCRIPT_PATH='notebooks/tycho/runai_test.py' -g 1 --cpu 12 --memory 64G \
        --pvc runai-upcourtine-klee-scratch:/home/klee/nas:rw -- /home/klee/run_script.sh

See ``run_script.sh`` for more details.

.. warning::

    The way it is implemented in ``run_script.sh``, the path to the script must be relative to the ``syn_decoder`` repository root.


Access the scratch directory
----------------------------

The scratch directory is located at ``/mnt/upcourtine/scratch/wyss/`` in the intermediate host.
To connect to the host, you can use the following command:

.. code-block:: bash

    ssh <username>@haas001.rcp.epfl.ch
    # example
    ssh klee@haas001.rcp.epfl.ch


To access the scratch directory from the container, the image must be built with the correct LDAP group and user.
You can then access the scratch directory by adding the following to the ``runai submit`` command:

- ``--pvc runai-upcourtine-klee-scratch:/path/to/mnt/point:rw``: to mount the scratch directory to the container in read/write mode


Run AI / Kubernetes useful commands
-----------------------------------

.. code-block:: bash

    # get the current user
    runai whoami
    # start a bash session in a running job
    runai bash job-0ff787b7bfd9
    # list all the jobs
    runai list jobs
    runai list jobs | grep ing
    # delete a job
    runai delete job job-0ff787b7bfd9
    # get the logs of a job
    runai logs job-0ff787b7bfd9
    # get the allocated resources of a job
    kubectl describe pod <pod-name>


Build and push a new image
--------------------------

To build a new image, pull this repository and run the following command:

.. code-block:: bash

    cd pytorch_nvidia
    docker build . --tag registry.rcp.epfl.ch/rcp-runai-upcourtine-<username>/<image-name>:<version> \
        --build-arg LDAP_GROUPNAME=rcp-runai-upcourtine --build-arg LDAP_GID=<group-id> \
        --build-arg LDAP_USERNAME=<username> --build-arg LDAP_UID=<user-id>
    
In the case of user ``klee``, the command is:

.. code-block:: bash

    docker build . --tag registry.rcp.epfl.ch/rcp-runai-upcourtine-klee/wyss_nvidia_pytorch_deps:latest \
    --build-arg LDAP_GROUPNAME=rcp-runai-upcourtine --build-arg LDAP_GID=123456 \
    --build-arg LDAP_USERNAME=klee --build-arg LDAP_UID=123456

.. note::

    The group id and name should be the same for all the images in the same group. To find your username and id, connect to
    the jump host and run the following command:

    .. code-block:: bash

        id
    
    The output should be something like this:

    ::

        uid=123456(klee) gid=123456(rcp-runai-upcourtine) groups=123456(rcp-runai-upcourtine),100(users)

.. note::

    Being connected to the EPFL VPN might cause issues with ``apt install`` and ``poetry install`` to build the image.
    If you encounter any issues, disconnect from the VPN.

To push the image to the registry, run the following command:

.. code-block:: bash

    docker push registry.rcp.epfl.ch/rcp-runai-upcourtine-<username>/<image-name>:<version>

.. note::

    You have to be connected to the EPFL VPN to push the image to the registry.


Other useful commands
---------------------

.. code-block:: bash

    find . -type f -name "log_runai_test_*"
