/**
  * npm installs - installs desired global modules
  * @license MIT
  * @author jh3y
*/
const PROPS   = {
  ERROR_MSG1: 'pip is not installed',
  ERROR_MSG2: 'pip3 is not installed',
};


const options = {
  name: 'pip installs',
  description: 'installs desired python packages',
  exec: function(resolve, reject, shell, log, config) {
    const pipWhich = shell.exec('which pip', {silent: true});
    if (pipWhich.output.trim() !== '') {
      const pips = config.pip;
      for (const pip of pips) {
        log.info(`attempting to install ${pip}`);
        shell.exec(`sudo pip install ${pip}`);
      }
    } else {
      log.error(PROPS.ERROR_MSG1);
    }

    const pip3Which = shell.exec('which pip3', {silent: true});
    if (pip3Which.output.trim() !== '') {
      const pips = config.pip3;
      for (const pip of pips) {
        log.info(`attempting to install ${pip}`);
        shell.exec(`sudo -H pip3 install ${pip}`);
      }
    } else {
      log.error(PROPS.ERROR_MSG2);
    }

    resolve();
  }
};

exports.options = options;
