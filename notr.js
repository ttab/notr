// Generated by CoffeeScript 1.9.3
(function() {
  var DEFAULTS, TRANS, css, distance, doc, later, margin, merge, notr, oneTrans, sel, stacks, styles,
    slice = [].slice;

  merge = function() {
    var i, k, len, o, os, t, v;
    t = arguments[0], os = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    for (i = 0, len = os.length; i < len; i++) {
      o = os[i];
      for (k in o) {
        v = o[k];
        if (v !== void 0) {
          t[k] = v;
        }
      }
    }
    return t;
  };

  doc = document;

  sel = function(s) {
    if (typeof s === 'string') {
      return doc.querySelector(s);
    } else {
      return s;
    }
  };

  distance = function(el) {
    return el.offsetTop + (el.offsetParent ? distance(el.offsetParent) : 0);
  };

  later = function(f) {
    return setTimeout(f, 1);
  };

  styles = ".notr {\n    min-width: 270px;\n    min-height: 20px;\n    margin-bottom: 3px;\n    margin-top: 0;\n    float: left;\n    clear: both;\n    opacity: 1.0;\n    background: white;\n    border: 1px solid #999;\n    padding: 5px;\n    box-shadow: 0 0 3px rgba(0,0,0,0.4);\n    transition: margin-top 0.2s, opacity 0.2s;\n    cursor: pointer;\n}\n.notrcont {\n    position: fixed;\n    min-width: 270px;\n    min-height: 20px;\n    z-index: 9000;\n}";

  css = doc.createElement('style');

  css.type = 'text/css';

  css.innerHTML = styles;

  doc.head.appendChild(css);

  stacks = {};

  margin = function(el, parent) {
    var dist, height;
    if (parent) {
      parent.appendChild(el);
    }
    dist = distance(el);
    height = el.offsetHeight;
    if (parent) {
      parent.removeChild(el);
    }
    return -1 * (height + dist);
  };

  TRANS = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'.split(' ');

  oneTrans = function(el, fn) {
    var cb, remove;
    cb = function(ev) {
      remove();
      return fn(ev);
    };
    remove = function() {
      return TRANS.forEach(function(t) {
        return el.removeEventListener(t, cb);
      });
    };
    return TRANS.forEach(function(t) {
      return el.addEventListener(t, cb);
    });
  };

  DEFAULTS = {
    html: 'Oh, why hallow thar!',
    className: 'alert alert-info',
    stack: 'def',
    stay: 4000
  };

  notr = function(opts, callback) {
    var div, remove, stack, timeout;
    if (opts == null) {
      opts = {};
    }
    if (typeof opts === 'string') {
      opts = {
        html: opts
      };
    }
    if (callback) {
      opts.callback = callback;
    }
    opts = merge({}, DEFAULTS, opts);
    div = doc.createElement('div');
    div.innerHTML = opts.html;
    div.className = "notr " + opts.className;
    stack = stacks[opts.stack];
    if (!stack) {
      return;
    }
    stack.attach();
    div.style.opacity = 0;
    div.style.marginTop = (margin(div, stack.container)) + "px";
    stack.container.appendChild(div);
    timeout = null;
    remove = function(ev) {
      if (timeout) {
        clearTimeout(timeout);
      }
      div.style.opacity = 0;
      div.style.marginTop = (margin(div)) + "px";
      if (typeof opts.callback === "function") {
        opts.callback(ev);
      }
      return oneTrans(div, function() {
        div.parentNode.removeChild(div);
        return stack.detachIfEmpty();
      });
    };
    div.onclick = remove;
    later(function() {
      div.style.marginTop = 0;
      div.style.opacity = null;
      if (opts.stay) {
        return oneTrans(div, (function() {
          return timeout = setTimeout(remove, opts.stay);
        }));
      }
    });
    return void 0;
  };

  notr.defineStack = function(name, parent, styles) {
    var el;
    stacks[name] = {
      container: el = doc.createElement('div'),
      attach: function() {
        var ref;
        return (ref = sel(parent)) != null ? ref.appendChild(el) : void 0;
      },
      detachIfEmpty: function() {
        var ref;
        if (!el.childNodes.length) {
          return (ref = el.parentNode) != null ? ref.removeChild(el) : void 0;
        }
      }
    };
    el.className = "notrcont notrcont-" + name;
    return merge(el.style, styles != null ? styles : {});
  };

  notr.defineStack('def', 'body', {
    top: '65px',
    right: '15px'
  });

  if (typeof module === 'object') {
    module.exports = notr;
  } else if (typeof define === 'function' && define.amd) {
    define(function() {
      return notr;
    });
  } else {
    this.notr = notr;
  }

}).call(this);

//# sourceMappingURL=notr.js.map
