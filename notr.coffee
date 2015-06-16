
merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t
doc = document
sel = (s) -> if typeof s is 'string' then  doc.querySelector(s) else s

distance = (el) -> el.offsetTop + if el.offsetParent then distance(el.offsetParent) else 0

later = (f) -> setTimeout f, 1

# inject our default styles
styles = """
    .notr {
        margin-top: 0;
        opacity: 1.0;
        float: left;
        clear: both;
        transition: margin-top 0.2s, opacity 0.2s;
        box-shadow: 0 0 2px rgba(0,0,0,0.4);
        padding: 9px 14px;
        border-radius: 5px;
        border: none;
        color: #666;
        margin-bottom: 3px;
        background: white;
        cursor: pointer;
    }
    .notrstack {
        position: fixed;
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
    className:    'alert alert-info'        # the class name (in addition to 'notr')
    stack:        'def'                     # name of the stack (notr.defineStack)
    stay:         4000                      # time to stay on screen
    id:           null                      # string identifier
    onclick:      null                      # click handler to override default

idof = (stack, id) -> "notr-#{stack}-#{id}"

notr = (opts = {}, callback) ->
    # set up the options
    opts = html:opts if typeof opts == 'string'
    opts.callback = callback if callback
    opts = merge {}, DEFAULTS, opts

    # ensure stack is there
    stack = stacks[opts.stack]
    return unless stack
    stack.attach()

    # find possible existing div
    div = doc.getElementById idof(opts.stack, opts.id) if opts.id
    # or create new notification div
    div = doc.createElement 'div' unless div

    # configure it
    div.id = idof(opts.stack, opts.id) if opts.id
    div.innerHTML = opts.html
    div.className = "notr #{opts.className}"

    # clear any previous
    clearTimeout div.timeout if div.timeout
    div.timeout = null
    div.callback = null

    dispatch = (name) ->
        evt = document.createEvent 'Event'
        evt.initEvent name, true, false
        div.dispatchEvent evt

    # starting point for transition
    unless div.show
        div.show = ->
            return if div.parentNode
            dispatch 'notr:beforeshow'
            div.style.opacity = 0
            div.style.marginTop = "#{margin(div, stack.container)}px"
            stack.container.appendChild div
            # transition in
            later ->
                div.style.marginTop = 0;
                div.style.opacity = null;
                oneTrans div, -> dispatch 'notr:show'


    # and show it (soon since someone receiving the returned div
    # may want to attach an event handler)
    later -> div.show?()

    # put latest callback in place.
    div.callback = opts.callback

    # function to hide again
    unless div.hide
        div.hide = (ev) ->
            return unless div.show # just once
            clearTimeout div.timeout if div.timeout
            # start transition
            div.style.opacity = 0
            div.style.marginTop = "#{margin(div)}px"
            cb = div.callback
            # cleanup
            div.hide = -> # make self inert (in case of repeated hide)
            div.show = null
            div.timeout = null
            div.callback = null
            # tell people about it
            dispatch 'notr:beforehide'
            # callback
            cb?(ev)
            # remove from dom
            oneTrans div, ->
                div.parentNode.removeChild div
                dispatch 'notr:hide'
                stack.detachIfEmpty()

    # click handler or remove
    div.onclick = if opts.onclick then opts.onclick else div.hide

    # schedule removal
    div.timeout = setTimeout div.hide, opts.stay if opts.stay > 0

    return div

notr.defineStack = (name, parent, styles) ->
    stacks[name] =
        container: el = doc.createElement 'div'
        attach: -> sel(parent)?.appendChild el
        detachIfEmpty: -> el.parentNode?.removeChild(el) unless el.childNodes.length
    el.className = "notrstack notrstack-#{name}"
    merge el.style, styles ? {}


# the default stack "def"
notr.defineStack 'def', 'body', {top:'65px', right:'15px'}

if typeof module == 'object'
    module.exports = notr
else if typeof define == 'function' and define.amd
    define -> notr
else
    this.notr = notr
