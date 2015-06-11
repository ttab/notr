
merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
doc = document
sel = (s) -> doc.querySelector(s)

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
        box-shadow: 0 0 5px rgba(0,0,0,0.5);
        transition: margin-top 0.2s, opacity 0.2s;
        cursor: pointer;
    }
    .notrcont {
        position: fixed;
        min-width: 270px;
        min-height: 10px;
        z-index: 9000;
    }
"""
css = doc.createElement('style')
css.type = 'text/css'
css.innerHTML = styles
doc.head.appendChild css

# each stack has a container element where each info message is a child
stacks = {}

# adds a stack for the given name (unless it already exists)
addStack = (name, styles) ->
    return if stacks[name]
    stacks[name] =
        container: el = doc.createElement 'div'
    el.className = "notrcont notrcont-#{name}"
    merge el.style, styles ? {}

# notification defaults
DEFAULTS =
    html:         'Oh, why hallow thar!'
    className:    'alert alert-info'
    stack:        'def'
    stackStyles:  {top:'65px', right:'15px'}
    parent:       'body'
    stay:         4000

# the default stack "def"
addStack 'def', DEFAULTS.stackStyles

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

TRANS = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'.split ' '

oneTrans = (el, fn) ->
    cb = (ev) -> remove(); fn(ev)
    remove = -> TRANS.forEach (t) -> el.removeEventListener t, cb
    TRANS.forEach (t) -> el.addEventListener t, cb

notr = (opts = {}) ->
    # set up the options
    opts = html:opts if typeof opts == 'string'
    opts = merge {}, DEFAULTS, opts

    # create new notification div
    div = doc.createElement 'div'
    div.innerHTML = opts.html
    div.className = "notr #{opts.className}"

    # ensure stack is there
    addStack opts.stack, opts.stackStyles
    stack = stacks[opts.stack]

    # figure out parent element where we insert stack
    parent = if typeof opts.parent is 'string' then sel(opts.parent) else opts.parent
    parent?.appendChild stack.container

    # starting point for transition
    div.style.opacity = 0
    div.style.marginTop = "#{margin(div, stack.container)}px"
    stack.container.appendChild div

    # when there are no children, remove
    removeStackIfEmpty = ->
        return unless stack.container.childNodes.length == 0
        stack.container.parentNode?.removeChild stack.container

    # function to remove again
    timeout = null
    remove = ->
        clearTimeout timeout if timeout
        div.style.opacity = 0
        div.style.marginTop = "#{margin(div)}px"
        # remove from dom
        oneTrans div, ->
            div.parentNode.removeChild div
            removeStackIfEmpty()

    # click removes
    div.onclick = remove

    # transition in
    later ->
        div.style.marginTop = 0;
        div.style.opacity = null;
        # schedule removal
        oneTrans div, (-> timeout = setTimeout remove, opts.stay) if opts.stay

    undefined

if typeof module == 'object'
    module.exports = notr
else if typeof define == 'function' and define.amd
    define -> notr
else
    this.notr = notr
