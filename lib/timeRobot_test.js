require('coffee-script')
var TimeRobot = require('./timeRobot')
var factual = require('./data_sources/factual').api


var options = {
  pois: {
    targets: {
      entities:[]
    },
    noises: {
      entities: []
    },
    home: null,
    work: null
  }
};

factual.get('/t/places', {
  q: 'starbucks',
  filters: {
    locality: "Los Angeles"
  },
  limit: 20
}, function (error, res) {
  options.pois.targets.entities = res.data;
  factual.get('/t/places', {
    filters: {
      locality: "Los Angeles"
    },
    limit: 50
  }, function (error, res) {
    options.pois.noises.entities = res.data;
    var tb = new TimeRobot(options);
    var d = new Date();
    var start = d.getTime() - 86400*20 - d.getTimezoneOffset() * 60;
    var end = start + 86400 * 14;
    console.log(tb.simEvents(start, end));
  });
});
