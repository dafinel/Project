var ObjectID = require('mongodb').ObjectID;

CollectionDriver = function(db) {
  this.db = db;
};

CollectionDriver.prototype.getCollection = function(collectionName, callback) {
  this.db.collection(collectionName, function(error, the_collection) {
    if( error ) callback(error);
    else callback(null, the_collection);
  });
};

//find all objects for a collection
CollectionDriver.prototype.findAll = function(collectionName, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
      if( error ) callback(error)
      else {
        the_collection.find().toArray(function(error, results) { //B
          if( error ) callback(error)
          else callback(null, results)
        });
      }
    });
};

//find a specific object
CollectionDriver.prototype.get = function(collectionName, id, callback) { //A
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
            var checkForHexRegExp = new RegExp("^[0-9a-fA-F]{24}$"); //B
            if (!checkForHexRegExp.test(id)) callback({error: "invalid id"});
            else the_collection.findOne({'_id':ObjectID(id)}, function(error,doc) { //C
            	if (error) callback(error)
            	else callback(null, doc);
            });
        }
    });
}

//find a user
CollectionDriver.prototype.getUser = function (collectionName, userName,password,callback) {
	this.getCollection (collectionName , function (error, the_collection) {
	    if (error) callback(error)
        else {
              the_collection.findOne({'name':userName , 'password':password}, function(error,doc) { //C
              if (error) callback(error)
               else callback(null, doc);
            });
        }
    });
}




//save new object
CollectionDriver.prototype.save = function(collectionName, obj, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
      if( error ) callback(error)
      else {
        obj.created_at = new Date(); //B
        the_collection.insert(obj, function() { //C
          callback(null, obj);
        });
      }
    });
};

//update a specific object
CollectionDriver.prototype.update = function(collectionName, obj, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
	        obj._id = ObjectID(entityId); //A convert to a real obj id
	        obj.updated_at = new Date(); //B
                the_collection.save(obj, function(error,doc) { //C
            	if (error) callback(error)
            	else callback(null, obj);
            });
        }
    });
}

// add meeting

CollectionDriver.prototype.addMeeting = function(collectionName,object,callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
	       the_collection.update({'_id':ObjectID(object.me)},
					{ $addToSet : {'meetings':{'with':object.with,
								   'lat':object.lat,
								   'lon':object.lon,
								   'date':new Date(object.date*1000)
								  }
						      }
    					 },
					function(error,doc) {
            				    the_collection.update({'_id':ObjectID(object.with)},
								  { $addToSet : {'meetings':{'with':object.me,
								   				'lat':object.lat,
								   				'lon':object.lon,
												'date':new Date(object.date*1000)
								  			    }
						      				}
    					 			  },
								 function(error,doc) {
            				    				if (error) callback(error)
            				    				else callback(null,doc);
                						 }
					    );	
                			}
		);

          }
    });
}

//delete meetings 

CollectionDriver.prototype.deleteMeetings = function(collectionName,callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
		the_collection.find({}, function(err, resultCursor) {
  				function processItem(err, item) {
   				 if(item === null) {
      					return; // All done!
    				} else {
				      the_collection.update({'_id':item._id},
							   {$pull:{'meetings':{'date':{ $lte: Date()}}}},
 								function(error,doc) {
            				    				
                						 }
				      );	
 				}

    				//externalAsyncFunction(item, function(err) {
								
      					resultCursor.nextObject(processItem);
    				//});

  				}

  			resultCursor.nextObject(processItem);
			}); 

          }
    });
}

//update location

CollectionDriver.prototype.updateLocation = function(collectionName,obj, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
		
		the_collection.update({'_id':ObjectID(entityId)},
					{ $set : {'curent_location':obj} },
					function(error,doc) { //C
            				    if (error) callback(error)
            				    else callback(null, obj);
                });

        }
    });
}
//accept friendship

CollectionDriver.prototype.accept = function(collectionName,idprieten,id,ok, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
		
	      if(ok == "yes")
	      {		
		 the_collection.update({'_id':ObjectID(id)},
					{ $addToSet : {'friends':{'_id':ObjectID(idprieten),'accepted':'yes'}} },
					function(error,doc) { 

						
						the_collection.update({'_id':ObjectID(idprieten)},
 									{$pull:{'friends':{'_id':id.toString(),'accepted':'no'}}},
									function(error,doc) {
										the_collection.update({'_id':ObjectID(idprieten)},
 													{$addToSet:{'friends':{'_id':id,'accepted':'yes'}}},
													function(error,doc) {
													       the_collection.update({'_id':ObjectID(id)},
																    {$pull:{'cereri':{'_id':idprieten}}},
																    function(error,doc) {		
																	if (error) callback(error)
            				    												else callback(null,doc);
																	}
														);
										});
									});
						
					}
					);
	      }	

        }
    });
}





//cerere prietenie

CollectionDriver.prototype.cerere = function(collectionName,entityId,mail, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
		var obj = the_collection.findOne({'mail':mail},function(error,obj) {

			var person = the_collection.findOne({'_id':ObjectID(entityId)},function(error,person) {
                 
			the_collection.update({'_id':ObjectID(entityId)},
					{ $addToSet : {'friends':{'_id':obj._id.valueOf(),'accepted':'no'}} },
					function(error,doc) { //C
					  console.log(obj);

					   the_collection.update({'_id':obj._id},
					        {$addToSet: { 'cereri':{'_id': entityId,'name':person.name}
							   }
					    },function(error,doc) {
						if (error) callback(error)
            				    else callback(null,obj);
						} );
            				    
			
                 			});
			});	
		
                });

        }
    });
}

// location History
CollectionDriver.prototype.locationHistory = function(collectionName,obj, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) {
        if (error) callback(error)
        else {
		console.log(obj);
		the_collection.update({'_id':ObjectID(entityId)},
					{ $addToSet : {'location_history':obj} },
					function(error,doc) { //C
            				    if (error) callback(error)
            				    else callback(null, obj);
                });

        }
    });
}



//delete a specific object
CollectionDriver.prototype.delete = function(collectionName, entityId, callback) {
    this.getCollection(collectionName, function(error, the_collection) { //A
        if (error) callback(error)
        else {
            the_collection.remove({'_id':ObjectID(entityId)}, function(error,doc) { //B
            	if (error) callback(error)
            	else callback(null, doc);
            });
        }
    });
}

exports.CollectionDriver = CollectionDriver;