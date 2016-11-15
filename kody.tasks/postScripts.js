
/**
  * Run post installation scripts
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'post scripts',
    description: 'run post installation scripts',
    exec: function(resolve, reject, shell, log, config) {
      const script = config.scripts.post;
      shell.exec(`${script}`);
      resolve();
    }
  };

exports.options = options;
