queue()
  .defer(d3.csv,'static/data/locations-v2.csv')
  .defer(d3.json,'static/maps/Abila.json')
  .await(draw);

var sp, pc, map;

function draw(error, data, world_map_json){
  if (error) throw error;

  //sp = new sp(data);
  //pc = new pc(data);
  map = new map(data, world_map_json);

}
