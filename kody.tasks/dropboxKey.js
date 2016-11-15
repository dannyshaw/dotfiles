
/**
  * install dropbox package repo
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'dropbox repo',
    description: 'install dropbox repo',
    exec: function(resolve, reject, shell, log, config) {
      shell.exec(`sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E`);
      shell.exec(`sudo sh -c 'echo "deb http://linux.dropbox.com/ubuntu/ xenial main" >> /etc/apt/sources.list.d/dropbox.list'`);
      log.success('Dropbox repository Installed');
      resolve();
    }
  };

exports.options = options;
