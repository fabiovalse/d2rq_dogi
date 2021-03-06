// Generated by CoffeeScript 1.10.0
(function() {
  var click, diagonal, distance, duration, g_link, g_node, labels, margin, max_depth, rsort, svg, tcmp, tree, update, width, zip;

  width = d3.select('body').node().getBoundingClientRect().width;

  distance = 25;

  max_depth = 5.5;

  margin = 30;

  duration = 750;

  labels = {
    'DoGi': ''
  };

  zip = function() {
    var args, shortest;
    args = [].slice.call(arguments);
    shortest = args.length === 0 ? [] : args.reduce((function(a, b) {
      if (a.length < b.length) {
        return a;
      } else {
        return b;
      }
    }));
    return shortest.map((function(_, i) {
      return args.map(function(array) {
        return array[i];
      });
    }));
  };

  tcmp = function(a, b) {
    var ai, bi, ci, j, len, ref, ref1;
    ref = zip(a.children, b.children);
    for (j = 0, len = ref.length; j < len; j++) {
      ref1 = ref[j], ai = ref1[0], bi = ref1[1];
      ci = tcmp(ai, bi);
      if (ci !== 0) {
        return ci;
      }
    }
    return b.children.length - a.children.length;
  };

  rsort = function(t) {
    var c, j, len, ref;
    ref = t.children;
    for (j = 0, len = ref.length; j < len; j++) {
      c = ref[j];
      if (c.children == null) {
        c.children = [];
      }
      rsort(c);
    }
    return t.children.sort(tcmp);
  };

  svg = d3.select('svg');

  g_link = svg.append('g').attr({
    transform: "translate(" + margin + ", " + margin + ")"
  });

  g_node = svg.append('g').attr({
    transform: "translate(" + margin + ", " + margin + ")"
  });

  d3.json('tree.json', function(error, root) {
    return d3.csv('label.csv', function(error, data_labels) {
      var collapse;
      data_labels.forEach(function(d) {
        var id;
        id = "" + d.ns + (d.nd !== 'NULL' ? '_' + d.nd : '');
        return labels[id] = d.label;
      });
      collapse = function(d) {
        if (d.children != null) {
          d._children = d.children;
          d._children.forEach(collapse);
          return d.children = null;
        }
      };
      rsort(root);
      root.children.forEach(collapse);
      return update(root);
    });
  });

  diagonal = d3.svg.diagonal().projection(function(d) {
    return [d.y, d.x];
  });

  tree = d3.layout.tree().size([0, 0]);

  update = function(root) {
    var filtered_node_enter, height, link, link_enter, links, node, node_enter, nodes, text, top_node_enter, tspans;
    height = 0;
    nodes = tree.nodes(root);
    links = tree.links(nodes);

    /* force the layout to display nodes in fixed rows and columns
     */
    nodes.forEach(function(n) {
      if ((n.parent != null) && n.parent.children[0] !== n) {
        height += distance;
      }
      n.x = height;
      return n.y = (n.depth - 1) * (width / max_depth) + 118;
    });
    svg.attr({
      width: width - margin,
      height: height - margin
    });

    /* links
     */
    link = g_link.selectAll('path.link').data(links.filter(function(d) {
      return d.source.depth > 0;
    }), (function(d) {
      return d.source.name + d.target.name;
    }));
    link.transition().duration(duration).attr({
      d: diagonal
    });
    link_enter = link.enter().append('path').attr({
      "class": 'link',
      d: diagonal
    }).style({
      opacity: 0
    });
    link_enter.transition().duration(duration).style({
      opacity: 0.3
    });
    link.exit().transition().duration(duration).style({
      opacity: 0
    }).remove();

    /* nodes
     */
    node = g_node.selectAll('g.node').data(nodes.filter(function(d) {
      return d.depth > 0;
    }), (function(d) {
      return d.name;
    }));
    node.transition().duration(duration).attr({
      transform: function(d) {
        return "translate(" + d.y + "," + d.x + ")";
      }
    });
    node_enter = node.enter().append('g').attr({
      "class": 'node',
      transform: function(d) {
        return "translate(" + d.y + "," + d.x + ")";
      }
    }).style({
      opacity: 0
    });
    node_enter.transition().duration(duration).style({
      opacity: 1
    });
    node_enter.append('circle').attr({
      r: 5
    }).on('click', function(d) {
      return click(d, root);
    });
    node.select('circle').attr({
      "class": function(d) {
        if (!((d.children != null) || ((d._children != null) && d._children.length > 0))) {
          return 'leaf';
        }
      },
      fill: function(d) {
        if ((d.children != null) || ((d._children != null) && d._children.length > 0)) {
          return '#fff';
        } else {
          return 'steelblue';
        }
      }
    });
    node.exit().transition().duration(duration).style({
      opacity: 0
    }).remove();

    /* text
     */
    top_node_enter = node_enter.filter(function(d) {
      return d.url === '';
    });
    filtered_node_enter = node_enter.filter(function(d) {
      return d.url !== '';
    });
    filtered_node_enter.append('a').attr({
      href: function(d) {
        return d.url;
      },
      target: '_blank'
    }).append('text').attr({
      "class": 'hoverable',
      y: 0
    });
    top_node_enter.append('text').attr({
      y: 0
    });
    text = node.select('text').attr({
      'text-anchor': function(d) {
        if ((d.children != null) || ((d._children != null) && d._children.length > 0)) {
          return 'end';
        } else {
          return 'start';
        }
      }
    });
    tspans = text.selectAll('tspan').data((function(d) {
      var words;
      words = d.url === '' ? d.name.split(' ') : labels[d.url.split('/').slice(-1)].split(' ');
      if (words.length > 1) {
        return [
          {
            text: words.slice(0, Math.floor(words.length / 2)).join(' '),
            is_leaf: !((d.children != null) || ((d._children != null) && d._children.length > 0))
          }, {
            text: words.slice(Math.floor(words.length / 2)).join(' '),
            is_leaf: !((d.children != null) || ((d._children != null) && d._children.length > 0))
          }
        ];
      } else {
        return [
          {
            text: words[0],
            is_leaf: !((d.children != null) || ((d._children != null) && d._children.length > 0))
          }
        ];
      }
    }));
    tspans.enter().append('tspan').attr({
      y: function(d, i) {
        return 3.45 + (i * 10);
      }
    }).text(function(d) {
      return d.text;
    });
    return tspans.attr({
      x: function(d) {
        if (d.is_leaf) {
          return 8;
        } else {
          return -8;
        }
      }
    });
  };

  click = function(d, root) {
    if (d.children != null) {
      d._children = d.children;
      d.children = null;
    } else {
      d.children = d._children;
      d._children = null;
    }
    return update(root);
  };

}).call(this);
