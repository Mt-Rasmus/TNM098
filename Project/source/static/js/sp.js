/*
  Created: Jan 14 2018
  Author: Kahin Akram Hassan
*/

function sp(data){

    this.data = data;
    var div = '#scatter-plot';

    var height = 500;
    var parentWidth = $(div).parent().width();
    var margin = {top: 20, right: 20, bottom: 60, left: 40},
        width = parentWidth - margin.right - margin.left,
        height = height - margin.top - margin.bottom;

    var color = d3.scaleOrdinal(d3.schemeCategory20);

    var tooltip = d3.select(div).append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

    var x = d3.scaleLinear().range([0, width]);
    var y = d3.scaleLinear().range([height, 0]);

    /* Task 2
      Initialize 4 (x,y,country,circle-size)
      variables and assign different data attributes from the data filter
      Then use domain() and extent to scale the axes


      x and y domain code here*/

    x.domain([d3.min(data, function(value) { return value.Household_income; }) - 5000, d3.max(data, function(value) { return value.Household_income; })]);
    y.domain([0,  d3.max(data, function(value) { return value.Life_satisfaction; })]);

    var circle_size = d3.scaleLinear()
        .domain([0, d3.max(data, function(value) { return value.Personal_earnings; })])
        .range([3,10]);


    var svg = d3.select(div).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform","translate(" + margin.left + "," + margin.top + ")");

        /* ~~ Task 3 Add the x and y Axis and title  ~~ */

        svg.append("g")
            .attr("class", "axis")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x));

        svg.append("text")
            .attr("transform",
                "translate(" + (width/2) + " ," +
                (height + margin.top + 20) + ")")
            .style("text-anchor", "middle")
            .text("Household Income");

        svg.append("g")
            .attr("class", "y axis")
            .call(d3.axisLeft(y));

        svg.append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 0 - margin.left)
            .attr("x",0 - (height / 2))
            .attr("dy", "1em")
            .style("text-anchor", "middle")
            .text("Life Satisfaction");

        svg.append("text")
            .attr("x", (width / 2))
            .attr("y", 0 - (margin.top / 4))
            .attr("text-anchor", "middle")
            .style("font-size", "16px")
            .style("text-decoration", "underline")
            .text("Household Income vs Life Satisfaction");

    /* ~~ Task 4 Add the scatter dots. ~~ */

        var circles = svg.selectAll("dot")
            .data(this.data)
            .enter().append("circle")
            .attr("r", function(d){return circle_size(d.Personal_earnings)})
            .attr("cx", function (d) {
                return x(d.Household_income);})
            .attr("cy", function (d) {
                return y(d.Life_satisfaction);})
            .style("fill", function(d){return color(d.Country);})
            .attr("class","non_brushed");


        /* ~~ Task 5 create the brush variable and call highlightBrushedCircles() ~~ */
        var brush = d3.brush()
            .on("brush", highlightBrushedCircles);

        svg.append("g")
            .call(brush);

         //highlightBrushedCircles function
         function highlightBrushedCircles() {
             if (d3.event.selection != null) {
                 // revert circles to initial style
                 circles.attr("class", "non_brushed");
                 var brush_coords = d3.brushSelection(this);
                 // style brushed circles
                   circles.filter(function (){
                            var cx = d3.select(this).attr("cx");
                            var cy = d3.select(this).attr("cy");
                            return isBrushed(brush_coords, cx, cy);
                  })
                  .attr("class", "brushed");
                   var d_brushed =  d3.selectAll(".brushed").data();


                   /* ~~~ Call pc or/and map function to filter ~~~ */
                   map.selectCountry(d_brushed);

             }
         }//highlightBrushedCircles
         function isBrushed(brush_coords, cx, cy) {
              var x0 = brush_coords[0][0],
                  x1 = brush_coords[1][0],
                  y0 = brush_coords[0][1],
                  y1 = brush_coords[1][1];
             return x0 <= cx && cx <= x1 && y0 <= cy && cy <= y1;
         }//isBrushed



         //Select all the dots filtered
         this.selecDots = function(value){
            var c = d3.selectAll("circle");

            c.style("stroke", function(d) {
                    return d.Country == value.properties.name ? "red": null;
                }
            );


         };


}//End
