var http = require('http'),
    express = require('express'),
    path = require('path'),
    MongoClient = require('mongodb').MongoClient,
    Server = require('mongodb').Server,
    CollectionDriver = require('./collectionDriver').CollectionDriver;
 
var app = express();
app.set('port', process.env.PORT || 3000); 
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.bodyParser()); // <-- add

var mongoHost = 'localHost'; //A
var mongoPort = 27017; 
var collectionDriver;
 
var mongoClient = new MongoClient(new Server(mongoHost, mongoPort)); //B
mongoClient.open(function(err, mongoClient) { //C
  if (!mongoClient) {
      console.error("Error! Exiting... Must start MongoDB first");
      process.exit(1); //D
  }
  var db = mongoClient.db("MyDatabase");  //E
  collectionDriver = new CollectionDriver(db); //F
});

app.use(express.static(path.join(__dirname, 'public')));
 
app.get('/', function (req, res) {
  res.send('<html><body><h1>Hello World</h1></body></html>');
});
 
app.get('/:collection', function(req, res) { //A
   var params = req.params; //B
   collectionDriver.findAll(req.params.collection, function(error, objs) { //C
    	  if (error) { res.send(400, error); } //D
	      else { 
	          if (req.accepts('html')) { //E
    	          res.render('data',{objects: objs, collection: req.params.collection}); //F
              } else {
	          res.set('Content-Type','application/json'); //G
                  res.send(200, objs); //H
              }
         }
   	});
});
 
app.get('/:collection/:entity', function(req, res) { //I
   var params = req.params;
   var entity = params.entity;
   var collection = params.collection;
   if (entity) {
       collectionDriver.get(collection, entity, function(error, objs) { //J
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //K
       });
   } else {
      res.send(400, {error: 'bad url', url: req.url});
   }
});

app.get('/:collection/:user/:password',function(req, res) {
    var params = req.params;
    var collection = params.collection;
    var userName = params.user; 
    var pass = params.password;
    
     if (userName) {
       collectionDriver.getUser(collection,userName,pass, function(error, objs) { //J
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //K
       });
   } else {
      res.send(400, {error: 'bad url', url: req.url});
   }



});

app.post('/:collection', function(req, res) { //A
    var object = req.body;
    var collection = req.params.collection;
    collectionDriver.save(collection, object, function(err,docs) {
          if (err) { res.send(400, err); } 
          else { res.send(201, docs); } //B
     });
});

app.put('/:collection/:id/:mail', function(req, res) { //A
    var collection = req.params.collection;
    var id = req.params.id;
    var mail = req.params.mail;
    collectionDriver.cerere(collection,id,mail, function(error, objs) { 
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C
         });          


});


app.put('/:collection/:accept/:idprieten/:id', function(req, res) { //A
    var collection = req.params.collection;
    var accept = req.params.accept;
    var id = req.params.id;
    var idprieten = req.params.idprieten;
    collectionDriver.accept(collection,idprieten,id,accept, function(error, objs) { 
	  
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C
         });          


});


app.put('/:collection/meet', function(req, res) { //A
    var params = req.params;
    var collection = params.collection;
    var object = req.body;
    console.log(object);
    collectionDriver.addMeeting(collection,object, function(error, objs) { 
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C
         });          
    

});



app.put('/:collection/:entity', function(req, res) { //A
    var params = req.params;
    var entity = params.entity; 
    var collection = params.collection;
    if (entity) {
       collectionDriver.updateLocation(collection, req.body, entity, function(error, objs) { 
	collectionDriver.locationHistory(collection, req.body, entity, function(error, objs) { 
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C
         });          
       });
	   } else {
       var error = { "message" : "Cannot PUT a whole collection" };
       res.send(400, error);
   }
});


//delete

app.delete('/:collection/:entity', function(req, res) { //A
    var params = req.params;
    var entity = params.entity;
    var collection = params.collection;
    if (entity) {
       collectionDriver.delete(collection, entity, function(error, objs) { //B
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C 200 b/c includes the original doc
       });
   } else {
       var error = { "message" : "Cannot DELETE a whole collection" }
       res.send(400, error);
   }
});


setInterval(function(){
  var collection = "users";
  collectionDriver.deleteMeetings(collection,function(error, objs) { //B
          if (error) { res.send(400, error); }
          else { res.send(200, objs); } //C 200 b/c includes the original doc
       });

  
}, 20*1000);     
 
app.use(function (req,res) {
    res.render('404', {url:req.url});
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});