/*
  Created: Jan 14 2018
  Author: Kahin Akram Hassan
*/
function map(data, world_map_json){

  //var smaller_data = data.slice(0,129);

    this.data = data;

  this.world_map_json = world_map_json;

  var div = '#world-map';
  var parentWidth = $(div).parent().width();
  var margin = {top: 0, right: 0, bottom: 0, left: 0},
            width = parentWidth - margin.left - margin.right,
            height = 500 - margin.top - margin.bottom;

  //TESTKOD BÖRJAR HÄR

        var projection = d3.geoEquirectangular().scale(1).translate([0,0]);
        //.center([60,40])
        //.scale(120);

    var path = d3.geoPath().projection(projection);

    var bounds = path.bounds(world_map_json);
    var s = .95 / Math.max((bounds[1][0] - bounds[0][0]) / width, (bounds[1][1] - bounds[0][1]) / height);
    var t = [(width - s * (bounds[1][0] + bounds[0][0])) / 2, (height - s * (bounds[1][1] + bounds[0][1])) / 2];

projection.scale(s).translate(t);

    var svg = d3.select(div).append("svg")
        .attr("width", width)
        .attr("height", height);
    var g = svg.append("g");

    svg.append("g")
        .attr("class", "tracts")
        .selectAll("path")
        .data(world_map_json.features)
        .enter().append("path")
        .attr("d", path)
        .attr("fill-opacity", 0.8)
        .attr("stroke", "#222");

    var geoData = {type: "FeatureCollection", features: geoFormat(data)};

    drawPoints();


    //Formats the data in a feature collection
    function geoFormat(array) {
        var data = [];

        array.map(function (d, i) {
            data.push({
                //Create five variables called :
                //id,type,geometry,mag and place and assign the corresponding value to is
                //geometry is an object and has two other attributes called coordinates and type.

                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates":[d.long, d.lat]
                },

                "id": d.id
                //"timestamp": d.Timestamp

            });
        });
        return data;
    }


    function drawPoints(){
        //draw point
        var point = g.selectAll(".point").data(geoData.features);
        point.enter().append("path")
            .attr("class", "point")
            .attr("d", path)
            .attr("d",path.pointRadius(2))
            .attr("fill","red");

    }

    //TESTKOD SLUTAR HÄR

  /*~~ Task 10  initialize color variable ~~*/

/*
  var color = d3.scaleOrdinal(d3.schemeCategory20);

  //initialize zoom
  var zoom = d3.zoom()
    .scaleExtent([1, 10])
    .on('zoom', move);

  //initialize tooltip
  var tooltip = d3.select(div).append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);


  /*~~ Task 11  initialize projection and path variable ~~*/

/*

  var projection = d3.geoMercator()
      .center([60,40])
      .scale(120);

  var path = d3.geoPath().projection(projection);
//--------------------------------------------------//

  var svg = d3.select(div).append("svg")
      .attr("width", width)
      .attr("height", height)
      .call(zoom);

  var g = svg.append("g");


  var countries = topojson.feature(world_map_json,
        world_map_json.objects.countries).features;

  var country = g.selectAll(".country").data(countries);

  /*~~ Task 12  initialize color array ~~*/

/*
  var cc = [];


  data.forEach(function (d) {
      cc[d.Country] = color(d.Country);
  })

  country.enter().insert("path")
      .attr("class", "country")

        /*~~ Task 11  add path variable as attr d here. ~~*/

/*
      .attr("d",path)

      .attr("id", function(d) { return d.id; })
      .attr("title", function(d) { return d.properties.name; })
      .style("fill", function(d) { return cc[d.properties.name]; })

      //tooltip
      .on("mousemove", function(d) {
        d3.select(this).style('stroke','white');

        tooltip.transition()
            .duration(200)
            .style("opacity", .9);
        var mouse = d3.mouse(svg.node()).map( function(d) { return parseInt(d); } );
        tooltip
        .attr("style", "left:"+(mouse[0]+30)+"px;top:"+(mouse[1]+30)+"px")
        .html(d.properties.name);
      })
      .on("mouseout",  function(d) {

          d3.select(this).style('stroke','none');
          tooltip.transition()
              .duration(500)
              .style("opacity", 0);
      })

      //selection
      .on("click",  function(d) {
          /*~~ call the other graphs method for selection here ~~*/
/*
          sp.selecDots(d);
      });

  function move() {
      g.style("stroke-width", 1.5 / d3.event.transform.k + "px");
      g.attr("transform", d3.event.transform);
  }

    /*~~ Highlight countries when filtering in the other graphs~~*/
/*
  this.selectCountry = function(value){
      var c = d3.selectAll(".country");
        c.style("stroke", function (d) {
            return value.every(function (p) {
                return d.properties.name != p.Country ? "red": null;
            })? null: "red";

        })
  }

*/

}
