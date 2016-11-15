
/**
  * Run pre installation scripts
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'pre scripts',
    description: 'run pre installation scripts',
    exec: function(resolve, reject, shell, log, config) {
      const script = config.scripts.pre;
      shell.exec(`${script}`);
      resolve();
    }
  };

exports.options = options;
