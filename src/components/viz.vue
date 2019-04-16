<template>
  <div>
    <div class="svg-container">
    </div>
  </div>
</template>

<script>

import * as d3 from 'd3'
import moment from 'moment'

export default {
  name: 'viz',
  data(){
    return {
      simulation: null
    }
  },
  props: {
    kills: {
      default: [],
      type: Array
    },
    stats: {
      default: [],
      type: Array
    }
  },
  mounted () {
    this.makeData()
    this.createViz()
    this.sortDots()
  },
  computed: {
    width () {
      var viewport_w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
      if (viewport_w < 860) {
        return viewport_w;
      } else {
        return 660;
      }
    },
    height () {
      return 500;
    },
    svg () {
      return d3.select(".svg-container").append("svg")
              .attr("width", this.width)
              .attr("height", this.height);
    }
  },
  methods: {
    makeData () {

      // Creates a complete array of objects, including kills for which there is no information
      var start_year = 2008
      var end_year = 2019
      // Counts the number of documented kills per year
      var documented_kills = {}
      for(var year = start_year; year <= end_year ; year++) {
        documented_kills[year] = {"pedestrian": 0, "cyclist": 0}
      }
      this.kills.forEach(function (killed){
        var date = moment(killed.date, "YYYY-MM-DD")
        documented_kills[date.year()][killed.victim_type]++
      })
      // Adds the non-documented kills
      for(var year = start_year; year <= end_year ; year++) {
        var kills_to_insert = {"pedestrian": 0, "cyclist": 0}
        var kill_types = ["pedestrian", "cyclist"]
        var self = this
        kill_types.forEach(function (killed_type) {
          kills_to_insert[killed_type] = self.stats[year - start_year][killed_type] - documented_kills[year][killed_type]
          for (var i=0; i < kills_to_insert[killed_type]; i++) {
            var random_date = moment({
              month: Math.floor(Math.random() * Math.floor(12)), 
              day: Math.floor(Math.random() * Math.floor(28)),
              year: year
              })
            self.kills.push({
              "date": random_date.format("YYYY-MM-DD"),
              "victim_type": killed_type,
              "undocumented": true
            })
          }
        })
      }
    },
    sortDots () {

      var current_year = moment().year();

      var xScale = d3.scaleLinear()
                            .domain([1,366])
                            .range([50, this.width - 50])
      var yScale = d3.scaleLinear()
                            .domain([2008,current_year])
                            .range([this.height - 50, 50])

      // Displays the years on the left of the graph
      var years = []
      for (var year = 2008; year <= current_year; year++){
        years.push(year)
      }

      this.svg.selectAll('text')
         .data(years)
         .enter()
         .append('text')
         .attr('x', 0)
         .attr('y', function(d) {
            return yScale(d) - 10;
          })
         .text(function(d) {
            return d;
          })
         .attr("class", "year-label");

      this.simulation.force('x', d3.forceX().x(function(d) {
                          return xScale(moment(d.date, "YYYY-MM-DD").dayOfYear());
                        }))
                        .force('y', d3.forceY().y(function(d) {
                            return yScale(moment(d.date, "YYYY-MM-DD").year());
                          }))
                        .force('collision', d3.forceCollide(6))
                        .force("charge_force", d3.forceManyBody().strength(1))
                        .alphaTarget(1).restart()
    },
    createViz () {

      // Prepares Tooltips
      var div = d3.select("body").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0);

      function makeCard(d) {
        return `
          <div class="card">
            <header class="card-header">
              <a class="card-header-icon" aria-label="close" onClick="var elems = document.getElementsByClassName('tooltip');for (var i = 0; i < elems.length; i++) {elems[i].style.opacity='0';elems[i].style['z-index']='-1'} ">
                <span class="icon">
                  <i class="fas fa-window-close" aria-hidden="true"></i>
                </span>
              </a>
            </header>
            <div class="card-content">
              <div class="content">
                ${d.long_summary}
              </div>
            </div>
          </div>
          `
      }

      this.simulation = d3.forceSimulation()
                        .nodes(this.kills)
                        .force("charge_force", d3.forceManyBody().strength(1))
                        .force("center_force", d3.forceCenter(this.width / 2, this.height / 2))
                        .force('collision', d3.forceCollide(6))
                        .on("tick", tickActions );

      var node = this.svg.append("g")
              .selectAll("circle")
              .data(this.kills)
              .enter()
              .append("circle")
              .attr("r", 5)
              .attr("fill", getColor)
              .attr("class", function(d) {return (d.undocumented ? "node" : "node-known")})
              .call(d3.drag()
                .subject(dragsubject)
                .on("start",dragstarted)
                .on("drag",dragged)
                .on("end",dragended))
              .on("click", function(d) {
                if (!d.undocumented) {
                  div.transition()
                   .duration(100)
                   .style("opacity", 1)
                   .style("z-index", 10);
                  div.html(makeCard(d))
                   .style("left", tooltipX)
                   .style("top", (d3.event.pageY - 28) + "px");
                }
               })
              
      var self = this;

      function tooltipX() {
        if (d3.event.pageX > self.width - 200) {
          return (d3.event.pageX - 200) + "px"
        } else {
          return (d3.event.pageX) + "px"

        }
        
      }

      function getColor(d) {
        if (d.undocumented) {return "#ddd"}
        else if (d.date_trial != null) {return "#2d616f"}
        else {return "#dbb64b"}
      }

      function dragstarted(d)
       { 
          if (!d3.event.active) self.simulation.alphaTarget(0).restart();
          d3.event.subject.fx = d3.event.subject.x;
          d3.event.subject.fy = d3.event.subject.y;
       }

       function dragsubject() {
          return self.simulation.find(d3.event.x, d3.event.y);
        }

       function dragged() {
          d3.event.subject.fx = d3.event.x;
          d3.event.subject.fy = d3.event.y;
        }

        function dragended() {
          if (!d3.event.active) self.simulation.alphaTarget(0.3);
          d3.event.subject.fx = null;
          d3.event.subject.fy = null;
        }

      function tickActions() {
        node
            .attr("cx", function(d) { return d.x; })
            .attr("cy", function(d) { return d.y; })
      }
    }
  }
}

</script>

<style lang="sass">

.svg-container
  width: 100%

.card
  max-width: 300px !important

div.tooltip
  position: absolute

.year-label
  font-size: 0.8em
  fill: #999

.node-known
  cursor: pointer
</style>
