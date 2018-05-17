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

    var zoom = d3.zoom()
        .scaleExtent([1, 10])
        .on('zoom', move);

    var tooltip = d3.select(div).append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

    //89.


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
        .attr("height", height)
        .call(zoom);

    var g = svg.append("g");

    /*svg.append("g")
        .attr("class", "tracts")
        .selectAll("path")
        .data(world_map_json.features)
        .enter().append("path")
        .attr("d", path)
        .attr("fill-opacity", 0.8)
        .attr("stroke", "#222"); */


    var street = g.selectAll(".street").data(world_map_json.features);

    street.enter().append("path")
        .attr("class", "street")
        .attr("d", path)
        .attr("id", function (d) { return d.TLID;})
        //.attr("title", function (d) { return d.FENAME + ' ' + d.FETYPE})
        .attr("stroke", "#222")
        .style("stroke-width", "2px")
        .on("mouseover", function (d) {

            d3.select(this).style("fill","blue").attr("stroke", "blue").style("stroke-width", "4px");

            tooltip.transition()
                .duration(200)
                .style("opacity", .9);
            var mouse = d3.mouse(svg.node()).map( function(d) { return parseInt(d); } );
            tooltip
                .attr("style", "left:"+(mouse[0]+30)+"px;top:"+(mouse[1]+30)+"px")
                .html(d.properties.FENAME + ' ' + d.properties.FETYPE);

        }) //d3.select(this).select("path").attr("stroke","blue")});
        .on("mouseout", function (d) {

            d3.select(this).style("fill","#222").attr("stroke", "#222").style("stroke-width", "2px");


        });


/*
    g.append("image")
        .attr("xlink:href","/static/maps/MC2-tourist.jpg")
        .attr("width", d3.select("g.tracts").node().getBBox().width + 4)
        .attr("height", d3.select("g.tracts").node().getBBox().height + 4)
        .attr("x", d3.select("g.tracts").node().getBBox().x)
        .attr("y", d3.select("g.tracts").node().getBBox().y)
        .attr("opacity", 1.0);

    d3.selectAll("image").lower();

*/
  //  var geoData = {type: "FeatureCollection", features: geoFormat(data)};

    var geoData = {type: "FeatureCollection", features: locationFormat(data)};

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


    function locationFormat(array)
    {
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

                "name": d.location

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
            .attr("d",path.pointRadius(4))
            .style("opacity",0.8)
            .attr("fill","red")
            .on("mouseover", function (d) {

                //d3.select(this).lower();
                d3.select(this).attr("d", path.pointRadius(7));

                tooltip.transition()
                    .duration(200)
                    .style("opacity", .9);
                var mouse = d3.mouse(svg.node()).map( function(d) { return parseInt(d); } );
                tooltip
                    .attr("style", "left:"+(mouse[0]+30)+"px;top:"+(mouse[1]+30)+"px")
                    .html(d.name);


            })

            .on("mouseout", function (d) {

                //d3.select(this).raise();
                d3.select(this).attr("d", path.pointRadius(4));


            })

    }

    function move() {
        g.style("stroke-width", 1.5 / d3.event.transform.k + "px");
        g.attr("transform", d3.event.transform);
    }



}
