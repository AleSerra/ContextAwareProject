const fs = require('fs');

const express = require('express');
const bodyParser = require('body-parser');

const { Client } = require('pg')
const client = new Client({
	user: "postgres",
	password: "password",
	host: "localhost",
	database: "postgres"
})

const app = express();

const initPOSTGRES = async () => {
	try{
		geofence_bike = await fs.readFileSync('.\\geofence\\geofence_bike.geojson', 'utf8').replace(/'/g, "\'\'");
		geofence_walk = await fs.readFileSync('.\\geofence\\geofence_walk.geojson', 'utf8').replace(/'/g, "\'\'");
		geofence_car = await fs.readFileSync('.\\geofence\\geofence_car.geojson', 'utf8').replace(/'/g, "\'\'");
		await client.connect()
		let exists;
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'geofence_bike'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.geofence_bike"+
								"(gid integer NOT NULL, "+
								"message character varying(512) COLLATE pg_catalog.\"default\", "+
								"geom geometry(Polygon,4326), "+
								"PRIMARY KEY (gid)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE public.geofence_bike "+
								"OWNER to postgres;")
			await client.query("INSERT INTO public.geofence_bike "+
								"WITH data AS (SELECT \'"+geofence_bike+"\' ::json AS fc) "+
								"SELECT "+
  								"row_number() OVER () AS gid, "+
  								"CAST(REPLACE(CAST((feat->'properties'->'message')AS varchar(512)),'\"','')AS varchar(512)) AS message, "+
  								"ST_SetSRID(ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')),4326) AS geom "+
								"FROM ("+
  								"SELECT json_array_elements(fc->'features') AS feat "+
  								"FROM data "+
								") AS f;")
		}
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'geofence_walk'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.geofence_walk"+
								"(gid integer NOT NULL, "+
								"message character varying(512) COLLATE pg_catalog.\"default\", "+
								"geom geometry(Polygon,4326), "+
								"PRIMARY KEY (gid)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE public.geofence_walk "+
								"OWNER to postgres;")
			await client.query("INSERT INTO public.geofence_walk "+
								"WITH data AS (SELECT \'"+geofence_walk+"\' ::json AS fc) "+
								"SELECT "+
  								"row_number() OVER () AS gid, "+
  								"CAST(REPLACE(CAST((feat->'properties'->'message')AS varchar(512)),'\"','')AS varchar(512)) AS message, "+
  								"ST_SetSRID(ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')),4326) AS geom "+
								"FROM ("+
  								"SELECT json_array_elements(fc->'features') AS feat "+
  								"FROM data "+
								") AS f;")
		}
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'geofence_car'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.geofence_car"+
								"(gid integer NOT NULL, "+
								"message character varying(512) COLLATE pg_catalog.\"default\", "+
								"geom geometry(Polygon,4326), "+
								"PRIMARY KEY (gid)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE public.geofence_car "+
								"OWNER to postgres;")
			await client.query("INSERT INTO public.geofence_car "+
								"WITH data AS (SELECT \'"+geofence_car+"\' ::json AS fc) "+
								"SELECT "+
  								"row_number() OVER () AS gid, "+
  								"CAST(REPLACE(CAST((feat->'properties'->'message')AS varchar(512)),'\"','')AS varchar(512)) AS message, "+
  								"ST_SetSRID(ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')),4326) AS geom "+
								"FROM ( "+
  								"SELECT json_array_elements(fc->'features') AS feat "+
  								"FROM data"+
								") AS f; ")
		}
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'user'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.user"+
								"(username character varying(512) COLLATE pg_catalog.\"default\", "+
								"password character varying(512) COLLATE pg_catalog.\"default\", "+
								"PRIMARY KEY (username)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE public.user "+
								"OWNER to postgres;")
		}

		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'user_activity_bike'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.user_activity_bike"+
								"(id SERIAL, "+
								"geom geometry(Point,4326), "+
								"username character varying(512) COLLATE pg_catalog.\"default\", "+
								"session date DEFAULT(now()), "+
								"registration BOOLEAN, "+
								"PRIMARY KEY (id), "+
								"FOREIGN KEY (username) REFERENCES public.user(username)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE user_activity_bike "+
								"OWNER to postgres;")
		}
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'user_activity_walk'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.user_activity_walk"+
								"(id SERIAL, "+
								"geom geometry(Point,4326), "+
								"username character varying(512) COLLATE pg_catalog.\"default\", "+
								"session date DEFAULT(now()), "+
								"registration BOOLEAN, "+
								"PRIMARY KEY (id), "+
								"FOREIGN KEY (username) REFERENCES public.user(username)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE user_activity_walk "+
								"OWNER to postgres;")
		}
		exists = await client.query("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'user_activity_car'");
		if(exists.rows[0]['count']==0)
		{
			await client.query("CREATE TABLE public.user_activity_car"+
								"(id SERIAL, "+
								"geom geometry(Point,4326), "+
								"username character varying(512) COLLATE pg_catalog.\"default\", "+
								"session date DEFAULT(now()), "+
								"registration BOOLEAN, "+
								"PRIMARY KEY (id), "+
								"FOREIGN KEY (username) REFERENCES public.user(username)) "+
								"TABLESPACE pg_default; "+
								"ALTER TABLE user_activity_car "+
								"OWNER to postgres;")
		}
	}
  	catch(e)
  	{
  		console.log(e);
  	}

};

initPOSTGRES();

// parse requests of content-type - application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }))

// parse requests of content-type - application/json
app.use(bodyParser.json())

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*"); // update to match the domain you will make the request from
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

app.get('/',  (req, res) => {
    res.json({"message": "Welcome to the ContextAwareProjectAPI"});
});

const checkGeoFence = async (lon, lat, activity, username) => {
  	let msg = await client.query(	"select * "+
									"from public.geofence_"+activity+" "+
									"where ST_Within(ST_SetSRID(ST_GeomFromText('POINT("+lon+" "+lat+")'), 4326), geom)");
  	if(msg["rowCount"]!=0)
  	{
  		var datetime = new Date();
  		let query = await client.query(	"SELECT geo.gid, geo.message "+
										"FROM public.geofence_"+activity+" as geo, public.user_activity_"+activity+" as ac "+
											"WHERE ac.session='"+datetime.toISOString().slice(0,10)+"' "+
											"AND ac.id = (SELECT MAX(id) FROM public.user_activity_"+activity+" WHERE username='"+username+"') "+
											"AND ST_Within(ac.geom, geo.geom)")
  		if(query["rowCount"]!=0 && msg["rows"][0]["gid"]==query["rows"][0]["gid"])
  			return ["User in the same geofence", false];
  		else
  			return [msg["rows"][0]["message"], true];
  	}
  	else
  		return ["No Geofence found", false]
};

const insertActivity = async (lon, lat, activity, username, registration) => {
  	client.query(	"INSERT INTO public.user_activity_"+activity+"(geom, username, registration) "+
					"VALUES (ST_SetSRID(ST_GeomFromText('POINT("+lon+" "+lat+")'), 4326), '"+username+"', "+registration+")");
};


app.get('/geofencecheck', async (req, res) => {
	response = await checkGeoFence(req.query.geometry.coordinates[1], req.query.geometry.coordinates[0], req.query.properties.activity, req.query.properties.user)
	insertActivity(req.query.geometry.coordinates[1], req.query.geometry.coordinates[0], req.query.properties.activity, req.query.properties.user, response[1])
	res.json({"message": response[0]});
});

const getGeoFences = async (activity) => {
	try{
		let query = await client.query(	"SELECT json_build_object("+
										"'type', 'FeatureCollection',"+
										"'features', json_agg("+
										    "json_build_object("+
										        "'type',       'Feature',"+
										        "'id',         gid,"+
										        "'geometry',   ST_AsGeoJSON(ST_ForceRHR(st_transform(geom,4326)))::json,"+
										        "'properties', jsonb_set(row_to_json(row (message))::jsonb,'{geom}','0',false)"+
										")))"+
										"FROM geofence_"+activity);
		let response = JSON.stringify(query["rows"][0]["json_build_object"]);
  		return JSON.parse(response.replace(/f1/g, "message"));
	}
  	catch (e){
  		return {"message": "No geofence founded with name geofence_"+activity}
  	}
};

app.get('/getgeofences', async (req, res) => {
	let response = await getGeoFences(req.query.activity)
	res.json(response);
});

const getUserNames = async () => {
	let query = await client.query("SELECT username "+
									"FROM public.user")
	return query["rows"];
};

app.get('/getusernames', async (req, res) => {
	let response = await getUserNames()
	res.json(response);
});

const generateGEOJSON = async (query) => {
	let i;
	let result = {
		type: "FeatureCollection",
		features: []
	}
	for(i=0; i<query.length; i++)
	{
		let feature = {
			type: "Feature",
			properties: {},
			geometry: query[i]["json_build_object"]
		}
		result["features"].push(feature);
	}
	return result;
}

const getUserPath = async (username, activity) => {
	let query;
	if(username!="all")
	{
		query = await client.query(	"SELECT json_build_object('type', 'LineString', "+
									"'coordinates', json_agg(ST_AsGeoJSON(geom)::json->'coordinates')) "+
									"FROM user_activity_"+activity+" "+
									"WHERE username='"+username+"' GROUP BY session");
	}
	else
	{
		query = await client.query(	"SELECT json_build_object('type', 'LineString', "+
									"'coordinates', json_agg(ST_AsGeoJSON(geom)::json->'coordinates')) "+
									"FROM user_activity_"+activity+" "+
									"GROUP BY session");
	}
	
	let result = await generateGEOJSON(query["rows"]);
	return result;
};

app.get('/getuserpath', async (req, res) => {
	let response = await getUserPath(req.query.username, req.query.activity)
	res.json(response);
});

const getGeoFenceStats = async (activity) => {
	let query = await client.query(	"SELECT geo.gid, "+
									"CAST(COUNT(*) AS FLOAT)/"+
									"	(SELECT COUNT(*) "+
									"	 FROM geofence_"+activity+" as geo1, user_activity_"+activity+" as act1 "+
									"	 WHERE ST_Within(act1.geom, geo1.geom) AND act1.registration=true) as perc "+
									"FROM geofence_"+activity+" as geo, user_activity_"+activity+" as act "+
									"WHERE ST_Within(act.geom, geo.geom) AND act.registration=true "+
									"GROUP BY geo.gid");
	return query["rows"];
};

//http://localhost:3600/getgeofencestats?activity=car
app.get('/getgeofencestats', async (req, res) => {
	let response = await getGeoFenceStats(req.query.activity);
	res.json(response);
});
const loginUser = async (username, password) => {
	let query = await client.query(	"SELECT COUNT(*) "+
									"FROM public.user "+
									"WHERE username='"+username+"' AND password='"+password+"'");
	return query["rows"];
};

app.post('/login', async (req, res) =>{
    let response = await loginUser(req.body.username, req.body.password);
	if(response[0]["count"]==1)
    	res.json({"login": "true"});
    else
    	res.json({"login": "false"});
});

const registerUser = async (username, password) => {
	try{
		let query = await client.query(	"INSERT INTO public.user(username, password) "+
									"VALUES ('"+username+"', '"+password+"')");
		return {"registration": "true"};
	}
	catch (e)
	{
		return {"registration": "false"};
	}
	
};

app.post('/register', async (req, res) =>{
    let response = await registerUser(req.body.username, req.body.password);	
    res.json(response);
});

const getClusterKMeans = async (activity) => {
	let query = await client.query(	"SELECT json_build_object( "+
									"'type', ST_AsGeoJSON(circle)::json->'type', "+
									"'coordinates',   ST_AsGeoJSON(circle)::json->'coordinates' "+
								 	")"+
									"FROM( "+
										"SELECT row_number() over () AS id, "+
										  "ST_NumGeometries(gc), "+
										  "gc AS geom_collection, "+
										  "ST_Centroid(gc) AS centroid, "+
										  "ST_MinimumBoundingCircle(gc) AS circle, "+
										  "sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius  "+
										"FROM ( "+
										  "SELECT ST_Collect(geom) gc "+
											"FROM( "+
												"SELECT ST_ClusterKMeans(geom, 3) OVER () as cluster, geom "+
												"FROM (	SELECT session, username, MAX(id) as id "+
														"FROM user_activity_"+activity+" "+
														"GROUP BY session, username "+
													  ") as arriveTable, user_activity_"+activity+" as t1 "+
												"WHERE t1.id = arriveTable.id"+
											") as clusters "+
											"GROUP BY cluster "+
										") collection "+
									") as cirle_cluster");
	let result = await generateGEOJSON(query["rows"]);
	return result;
};

app.get('/getclusterkmeans', async (req, res) => {
	let response = await getClusterKMeans(req.query.activity);
	res.json(response);
});

// listen for requests
app.listen(3600, () => {
    console.log("Server is listening on port 3600");
});