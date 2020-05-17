const fs = require('fs');

const { Client } = require('pg')
const client = new Client({
	user: "postgres",
	password: "password",
	host: "localhost",
	database: "postgres"
})

let user = [];

const main = async () => {
	try{
		path_bike_txt = await fs.readFileSync('path_bike.geojson', 'utf8').replace(/'/g, "\'\'");
		path_walk_txt = await fs.readFileSync('path_walk.geojson', 'utf8').replace(/'/g, "\'\'");
		path_car_txt = await fs.readFileSync('path_car.geojson', 'utf8').replace(/'/g, "\'\'");
		path_bike = JSON.parse(path_bike_txt);
		path_walk = JSON.parse(path_walk_txt);
		path_car = JSON.parse(path_car_txt);
		user[0] = "AleSerra";
		user[1] = "LucaDAmbro";
		await client.connect();
		let i, j;
		for(i=0; i<user.length; i++)
		{
			try{
				let query = await client.query(	"INSERT INTO public.user(username, password) "+
											"VALUES ('"+user[i]+"', '1234567')");
			}
			catch (e)
			{
				console.log("Utente "+user[i]+" già registrato");
			}
		}
				
		//bike
		for(i=0; i<path_bike["features"].length; i++)
		{
			console.log(i);
			for(j=0; j<path_bike["features"][i]["geometry"]["coordinates"].length; j++)
			{
				console.log(path_bike["features"][i]["geometry"]["coordinates"][j]);
				let msg = await client.query(	"select * "+
									"from public.geofence_bike "+
									"where ST_Within(ST_SetSRID(ST_GeomFromText('POINT("+path_bike["features"][i]["geometry"]["coordinates"][j][0]+" "+path_bike["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), geom)");
				let registration = false;
				var datetime = new Date();
				datetime.setDate(datetime.getDate() - i - 1);
				if(msg["rowCount"]!=0)
  				{					
			  		let query = await client.query(	"SELECT geo.gid, geo.message "+
													"FROM public.geofence_bike as geo, public.user_activity_bike as ac "+
														"WHERE ac.session='"+datetime.toISOString().slice(0,10)+"' "+
														"AND ac.id = (SELECT MAX(id) FROM public.user_activity_bike WHERE username='"+user[i%2]+"') "+
														"AND ST_Within(ac.geom, geo.geom)");
			  		
			  		if(query["rowCount"]!=0 && msg["rows"][0]["gid"]==query["rows"][0]["gid"])
			  			registration = false;
			  		else
			  			registration = true;
				}
				await client.query(	"INSERT INTO public.user_activity_bike(geom, username, session, registration) "+
									"VALUES (ST_SetSRID(ST_GeomFromText('POINT("+path_bike["features"][i]["geometry"]["coordinates"][j][0]+" "+path_bike["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), '"+user[i%2]+"', '"+datetime.toISOString().slice(0,10)+"',"+registration+")");
			}
		}
		//car
		for(i=0; i<path_car["features"].length; i++)
		{
			console.log(i);
			for(j=0; j<path_car["features"][i]["geometry"]["coordinates"].length; j++)
			{
				console.log(path_car["features"][i]["geometry"]["coordinates"][j]);
				let msg = await client.query(	"select * "+
									"from public.geofence_car "+
									"where ST_Within(ST_SetSRID(ST_GeomFromText('POINT("+path_car["features"][i]["geometry"]["coordinates"][j][0]+" "+path_car["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), geom)");
				let registration = false;
				var datetime = new Date();
				datetime.setDate(datetime.getDate() - i - 1);
				if(msg["rowCount"]!=0)
  				{					
			  		let query = await client.query(	"SELECT geo.gid, geo.message "+
													"FROM public.geofence_car as geo, public.user_activity_car as ac "+
														"WHERE ac.session='"+datetime.toISOString().slice(0,10)+"' "+
														"AND ac.id = (SELECT MAX(id) FROM public.user_activity_car WHERE username='"+user[i%2]+"') "+
														"AND ST_Within(ac.geom, geo.geom)");
			  		
			  		if(query["rowCount"]!=0 && msg["rows"][0]["gid"]==query["rows"][0]["gid"])
			  			registration = false;
			  		else
			  			registration = true;
				}
				await client.query(	"INSERT INTO public.user_activity_car(geom, username, session, registration) "+
									"VALUES (ST_SetSRID(ST_GeomFromText('POINT("+path_car["features"][i]["geometry"]["coordinates"][j][0]+" "+path_car["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), '"+user[i%2]+"', '"+datetime.toISOString().slice(0,10)+"',"+registration+")");
			}
		}
		//walk
		for(i=0; i<path_walk["features"].length; i++)
		{
			console.log(i);
			for(j=0; j<path_walk["features"][i]["geometry"]["coordinates"].length; j++)
			{
				console.log(path_walk["features"][i]["geometry"]["coordinates"][j]);
				let msg = await client.query(	"select * "+
									"from public.geofence_walk "+
									"where ST_Within(ST_SetSRID(ST_GeomFromText('POINT("+path_walk["features"][i]["geometry"]["coordinates"][j][0]+" "+path_walk["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), geom)");
				let registration = false;
				var datetime = new Date();
				datetime.setDate(datetime.getDate() - i  - 1);
				if(msg["rowCount"]!=0)
  				{					
			  		let query = await client.query(	"SELECT geo.gid, geo.message "+
													"FROM public.geofence_walk as geo, public.user_activity_walk as ac "+
														"WHERE ac.session='"+datetime.toISOString().slice(0,10)+"' "+
														"AND ac.id = (SELECT MAX(id) FROM public.user_activity_walk WHERE username='"+user[i%2]+"') "+
														"AND ST_Within(ac.geom, geo.geom)");
			  		
			  		if(query["rowCount"]!=0 && msg["rows"][0]["gid"]==query["rows"][0]["gid"])
			  			registration = false;
			  		else
			  			registration = true;
				}
				await client.query(	"INSERT INTO public.user_activity_walk(geom, username, session, registration) "+
									"VALUES (ST_SetSRID(ST_GeomFromText('POINT("+path_walk["features"][i]["geometry"]["coordinates"][j][0]+" "+path_walk["features"][i]["geometry"]["coordinates"][j][1]+")'), 4326), '"+user[i%2]+"', '"+datetime.toISOString().slice(0,10)+"',"+registration+")");
			}
		}
	}
  	catch(e)
  	{
  		console.log(e);
  	}

};

main();