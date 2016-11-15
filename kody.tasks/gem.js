/**
  * npm installs - installs desired global modules
  * @license MIT
  * @author jh3y
*/
const PROPS   = {
    ERROR_MSG: 'ruby gems is not installed',
  },
  options = {
    name: 'gem installs',
    description: 'installs desired ruby gems',
    exec: function(resolve, reject, shell, log, config) {
      const gemWhich = shell.exec('which gem', {silent: true});
      if (gemWhich.output.trim() !== '') {
        const gems = config.rubyGems;
        for (const gem of gems) {
          log.info(`attempting to install ${gem}`);
          shell.exec(`sudo gem install ${gem}`);
        }
      } else
        log.error(PROPS.ERROR_MSG);
      resolve();
    }
  };

exports.options = options;
