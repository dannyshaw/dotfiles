
/**
  * install google signing key for chrome
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'chrome google key',
    description: 'install google signing key for chrome',
    exec: function(resolve, reject, shell, log, config) {
      shell.exec(`wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -`);
      shell.exec(`sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'`);
      log.success('Google Chrome Signing Key Installed');
      resolve();
    }
  };

exports.options = options;
