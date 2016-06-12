// const async = require('async');
/**
  * ppa repository install
  * @license MIT
  * @author dannyshaw
*/
const options = {
    name: 'ppa',
    description: 'install ppa repositories',
    exec: function(resolve, reject, shell, log, config) {
      ppas = config.ppaRepos;
      if (ppas.length > 0) {
        // async.forEachSeries(ppas, function (ppa, done) {
        ppas.forEach(function (ppa) {
        shell.exec(`sudo add-apt-repository -y ${ppa}`);
        //   done()
      });
        log.success('ppa repos installed');
      }
      resolve();
    }
  };

exports.options = options;
