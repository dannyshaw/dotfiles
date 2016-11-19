/**
  * npm installs - installs desired global modules
  * @license MIT
  * @author jh3y
*/
const PROPS   = {
    ERROR_MSG: 'pip is not installed',
  },
  options = {
    name: 'pip installs',
    description: 'installs desired python packages',
    exec: function(resolve, reject, shell, log, config) {
      const gemWhich = shell.exec('which pip', {silent: true});
      if (gemWhich.output.trim() !== '') {
        const pips = config.pip;
        for (const pip of pips) {
          log.info(`attempting to install ${pip}`);
          shell.exec(`sudo pip install ${pip}`);
        }
      } else
        log.error(PROPS.ERROR_MSG);
      resolve();
    }
  };

exports.options = options;
