// Generated by CoffeeScript 1.10.0
(function() {
  var bar_height, class_height, classes_amounts, data, left_padding, svg;

  left_padding = 150;

  class_height = 30;

  bar_height = 15;

  classes_amounts = {};

  data = [
    {
      "class": "Journal",
      "desc": "Academic contributions published within an issue of an Italian legal journal.",
      "translation": "",
      "table": "tabRiviste",
      "main": true
    }, {
      "class": "Issue",
      "desc": "Periodical publications of Italian legal journals.",
      "translation": "",
      "table": "tabRifBibl",
      "main": true
    }, {
      "class": "Article",
      "desc": "Academic articles published within an issue of an Italian legal journals.",
      "translation": "",
      "table": "tabDocumenti",
      "main": true
    }, {
      "class": "Classification",
      "desc": "Scheme codes, specifically developed within DoGi, for classifying academic legal articles (i.e., a pair sistematico-descrittore or a sistematico).",
      "translation": "",
      "table": "tabClassificazioni",
      "main": true
    }, {
      "class": "Source Of Law",
      "desc": "Legislative or jurisprudential sources cited in the contribution.  They can be international, European  national, regional sources and can be represented as a whole or as a specific partition (article, paragraph, letter, item or annex…).",
      "translation": "",
      "table": "tabSourceOfLaw",
      "main": true
    }, {
      "class": "Agent",
      "desc": "Authority (person or organization) responsible of the authorship of an academic contribution.",
      "translation": "",
      "table": "tabResponsabilita",
      "main": true
    }, {
      "class": "Bibliography Type",
      "desc": "Types of bibliography used by a certain academic contribution (e.g., at the end of the article, footnote).",
      "translation": "",
      "table": "tabBib",
      "main": true
    }, {
      "class": "Descrittore",
      "desc": "An additional descriptor associated to a sistematico for better qualifying its context and meaning.",
      "translation": "",
      "table": "tabDescrittori",
      "main": false
    }, {
      "class": "Sistematico",
      "desc": "A descriptor for legal documentation identifying a certain law branch (e.g., Administrative Law, Civil Law, Criminal Law).",
      "translation": "",
      "table": "tabSistematici",
      "main": false
    }
  ];

  svg = d3.select('svg').attr({
    height: data.filter(function(d) {
      return d.main === true;
    }).length * class_height
  }).append('g').attr({
    transform: "translate(0, 20)"
  });

  d3.json("snorql/data/classes.json", function(classes_data) {

    /* Since there is not a direct mapping between rdf:type and class label
        a index for storing classes amounts is created
     */
    var c, classes, enter_classes, i, key, other_classes, ref, title_desc, x, y;
    ref = classes_data.results.bindings;
    for (i in ref) {
      c = ref[i];
      key = c.c.value.split('/').slice(-1)[0].replace('#', '');
      if (key === 'Person' || key === 'Organization') {
        if ('Agent' in classes_amounts) {
          classes_amounts['Agent'] += parseInt(c.cont.value);
        } else {
          classes_amounts['Agent'] = parseInt(c.cont.value);
        }
      } else if (key === 'Location') {
        classes_amounts['Country'] = parseInt(c.cont.value);
      } else {
        classes_amounts[key] = parseInt(c.cont.value);
      }
    }
    x = d3.scale.pow().exponent(0.3).range([0, d3.select('#main').node().getBoundingClientRect().width / 2]).domain([
      0, d3.max(classes_data.results.bindings, function(d) {
        return parseInt(d.cont.value);
      })
    ]);
    y = d3.scale.ordinal().rangeRoundBands([0, 300], .5).domain(data.map(function(d, i) {
      return i;
    }));

    /* MAIN Classes
     */

    /*classes = d3.select('#main_classes').selectAll 'tr'
      .data data.filter (d) -> d.main is true
    
    enter_classes = classes.enter().append 'tr'
    
    a = enter_classes.append 'a'
      .attr
        href: (d) -> "directory/#{d.table}"
      .append 'td'
        .text (d) -> d.class
    
    enter_classes.append 'td'
      .text (d) -> "#{d.desc}"
     */
    classes = d3.select('#main_classes').selectAll('div').data(data.filter(function(d) {
      return d.main;
    }));
    enter_classes = classes.enter().append('div').attr({
      "class": 'main_class'
    });
    enter_classes.append('div').attr({
      "class": 'square major'
    });
    title_desc = enter_classes.append('div').attr({
      "class": 'title_desc'
    });
    title_desc.append('a').attr({
      href: function(d) {
        return "directory/" + d.table;
      }
    }).text(function(d) {
      return d["class"];
    });
    title_desc.append('div').text(function(d) {
      return "" + d.desc;
    });

    /* OTHER Classes
     */
    d3.select('#other_classes').append('div').attr({
      "class": 'square minor'
    });
    other_classes = d3.select('#other_classes').selectAll('span').data(data.filter(function(d) {
      return d.main === false;
    }));
    other_classes.enter().append('span').html(function(d, i) {
      if (i > 0) {
        return ", <a href='directory/" + d.table + "'>" + d["class"] + "</a>";
      } else {
        return "<a href='directory/" + d.table + "'>" + d["class"] + "</a>";
      }
    });

    /* CLASSES BAR-CHART
     */
    classes = svg.selectAll('.class').data(data.filter(function(d) {
      return d.main;
    }).sort(function(a, b) {
      return d3.descending(classes_amounts[a["class"].replace(/ /g, '')], classes_amounts[b["class"].replace(/ /g, '')]);
    }));
    classes.enter().append('g').attr({
      "class": 'class'
    });
    classes.append('rect').attr({
      "class": 'bar',
      x: left_padding,
      y: function(d, i) {
        return y(i);
      },
      width: function(d) {
        return x(classes_amounts[d["class"].replace(/ /g, '')]);
      },
      height: bar_height
    });
    classes.append('text').attr({
      "class": 'title',
      'text-anchor': 'end',
      x: left_padding - 10,
      y: function(d, i) {
        return y(i) + bar_height / 1.4;
      }
    }).text(function(d) {
      return d["class"];
    }).append('title').text(function(d) {
      return "" + d.desc;
    });
    return classes.append('text').attr({
      "class": 'bar_amount',
      x: function(d) {
        return left_padding + x(classes_amounts[d["class"].replace(/ /g, '')]) + 5;
      },
      y: function(d, i) {
        return y(i) + bar_height / 1.4;
      }
    }).text(function(d) {
      return classes_amounts[d["class"].replace(/ /g, '')];
    }).append('title').text(function(d) {
      return classes_amounts[d["class"].replace(/ /g, '')] + " instances of type " + d["class"];
    });
  });

}).call(this);
