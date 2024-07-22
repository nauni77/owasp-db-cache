# owasp-db-cache
This is just the documentation for the forked version.

## release process
There are problems with gitlab to update git repository from github. Because of these Problems I release for now
the containers with the Makefile and enter the version as variable.

## enhancements
- restarting the container will not cause a complete download of the database - keep the cached data.
- possibility to define the rate for refresh database - default 1h