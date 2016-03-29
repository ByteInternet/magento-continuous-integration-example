# Install test dependencies
For this example, make sure you have the following installed:
- ansible 
- python-nose (or install nose in a virtualenv)
- python-selenium (or install selenium in a virtualenv)
- <a href=”https://gist.github.com/julionc/7476620”>PhantomJS</a>

Configure sudoers file for vagrant-hostmanager plugin
```
# sudo visudo
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp /var/lib/jenkins/.vagrant.d/tmp/hosts.local /etc/hosts
jenkins   ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
```
