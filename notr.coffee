
merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
doc = document
sel = (s) -> if typeof s is 'string' then  doc.querySelector(s) else s

distance = (el) -> el.offsetTop + if el.offsetParent then distance(el.offsetParent) else 0

later = (f) -> setTimeout f, 1

# inject our default styles
styles = """
    .notr {
        min-width: 270px;
        min-height: 20px;
        margin-bottom: 3px;
        margin-top: 0;
        float: left;
        clear: both;
        opacity: 1.0;
        background: white;
        border: 1px solid #999;
        padding: 5px;
        box-shadow: 0 0 3px rgba(0,0,0,0.4);
        transition: margin-top 0.2s, opacity 0.2s;
        cursor: pointer;
    }
    .notrcont {
        position: fixed;
        min-width: 270px;
        min-height: 20px;
        z-index: 9000;
    }
"""
css = doc.createElement('style')
css.type = 'text/css'
css.innerHTML = styles
doc.head.appendChild css

# each stack has a container element where each info message is a child
stacks = {}

# calculate the margin needed to hide the element
margin = (el, parent) ->
    # add element
    parent.appendChild el if parent
    # to get distance to top of screen and height of message
    dist = distance el
    height = el.offsetHeight

    # but not yet
    parent.removeChild el if parent

    # which we use to calculate the margin
    -1 * (height + dist)

# helper function to get exactly one transition event
TRANS = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'.split ' '
oneTrans = (el, fn) ->
    cb = (ev) -> remove(); fn(ev)
    remove = -> TRANS.forEach (t) -> el.removeEventListener t, cb
    TRANS.forEach (t) -> el.addEventListener t, cb

# notification defaults
DEFAULTS =
    html:         'Oh, why hallow thar!'    # the html body
    className:    'alert alert-info'        # the class name
    stack:        'def'                     # name of the stack (notr.defineStack)
    stay:         4000                      # time to stay on screen

notr = (opts = {}, callback) ->
    # set up the options
    opts = html:opts if typeof opts == 'string'
    opts.callback = callback if callback
    opts = merge {}, DEFAULTS, opts

    # create new notification div
    div = doc.createElement 'div'
    div.innerHTML = opts.html
    div.className = "notr #{opts.className}"

    # ensure stack is there
    stack = stacks[opts.stack]
    return unless stack
    stack.attach()

    # starting point for transition
    div.style.opacity = 0
    div.style.marginTop = "#{margin(div, stack.container)}px"
    stack.container.appendChild div

    # function to remove again
    timeout = null
    remove = (ev) ->
        clearTimeout timeout if timeout
        div.style.opacity = 0
        div.style.marginTop = "#{margin(div)}px"
        opts.callback?(ev)
        # remove from dom
        oneTrans div, ->
            div.parentNode.removeChild div
            stack.detachIfEmpty()

    # click removes
    div.onclick = remove

    # transition in
    later ->
        div.style.marginTop = 0;
        div.style.opacity = null;
        # schedule removal
        oneTrans div, (-> timeout = setTimeout remove, opts.stay) if opts.stay

    undefined

notr.defineStack = (name, parent, styles) ->
    stacks[name] =
        container: el = doc.createElement 'div'
        attach: -> sel(parent)?.appendChild el
        detachIfEmpty: -> el.parentNode?.removeChild(el) unless el.childNodes.length
    el.className = "notrcont notrcont-#{name}"
    merge el.style, styles ? {}


# the default stack "def"
notr.defineStack 'def', 'body', {top:'65px', right:'15px'}

if typeof module == 'object'
    module.exports = notr
else if typeof define == 'function' and define.amd
    define -> notr
else
    this.notr = notr
