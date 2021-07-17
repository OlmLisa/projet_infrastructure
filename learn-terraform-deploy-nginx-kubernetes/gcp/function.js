/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.helloWorld = (req, res) => {
var http = require("http");
var url = process.env.URL
//var url = "34.135.31.0"

var options = {
  host: url,
  port: 80,
  path: '/',
  method: 'GET'
};

var req = http.request(options, function(_res, result) {
  console.log('STATUS: ' + _res.statusCode);
  console.log('HEADERS: ' + JSON.stringify(_res.headers));
  _res.setEncoding('utf8');
  _res.on('data', function (chunk) {
    console.log('BODY: ' + chunk);
  });
});

req.on('error', function(e) {
  console.log('problem with request: ' + e.message);
});

// write data to request body
req.write('data\n');
req.write('data\n');
req.end();
//console.log(req)
//let message = req.query.message || req.body.message || 'Hello World!';
//res.status(200).send(message);

};
//this.helloWorld()
