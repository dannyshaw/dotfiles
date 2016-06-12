
/**
  * apt packages install
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'apt',
    description: 'install apt packages',
    exec: function(resolve, reject, shell, log, config) {
      packages = config.aptInstalls;
      shell.exec(`sudo apt-get update`);
      if (packages.length > 0) {
        shell.exec(`sudo apt-get install ${packages.join(' ')}`);
        log.success('apt packages installed');
      }
      resolve();
    }
  };

exports.options = options;
