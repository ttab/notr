notr
====

## Motivation

There are a ton of complicated notification frameworks out there. What I need is:

* Simple (no need for different animations)
* Simple (no jQuery)
* Simple (no built in icons)
* Simple (reasonable defaults)

## Compatibility

* IE9+, FF, Chrome, Safari, iOS5+, Android

Note that the transition effect may not work devices not supporting
the `transition` CSS style.

## Installing with NPM

```bash
npm install -S notr
```

### Installing with Bower

```bash
bower install -S notr
```

## Usage

Require it

```coffee
notr = require('notr')
```

Simple message, shows for 4 seconds.

```coffee
notr('Hello <b>World!</b>')
```

Complicated message, stays until clicked.

```coffee
notr({
    html: 'Hello <b>World!</b>'
    stay: 0
})
```

Hide message manually.

```coffee
el = notr({
    html: 'Hello <b>World!</b>'
    stay: 0
})

... # sometime later

el.hide() # div is extended with hide function
```

Callback on hide

```javascript
notr('Hello <b>World!</b>', function() {
    console.log('it closed');
});
```

Change content of existing

```
notr({
    html: 'Hello <b>World!</b>'
    id: 'myhello'
})

... # sometime later

notr({
    html: 'Goodbye cruel world!'
    id: 'myhello'
})
```

## API

#### notr(html, callback)

Short form, equivalent to `el = notr({html:html, callback:callback})`

#### notr(opts)

Show a notification with possible options. Returns the `<div>` element.

args        | desc
:---------- | :-----------------
`html`      | Text `.innerHTML` of the notification `<div>`.
`className` | `.className` of `<div>` in addition to `"notr"`. Default `"alert alert-info"`
`stack`     | Stack to place the notification in. See `notr.defineStack()`. Default `"def"`
`stay`      | Milliseconds to stay on screen. 0 to stay forever. Default 4000
`id`        | Id to change content/settings of notification on subsequent calls. Default `null`
`onclick`   | Click handler. Default `null` which hides the `<div>`
`callback`  | Callback when notification is about to hide.

Returns `<div>` extended with a `.hide()` function.

#### notr.defineStack(name, parent, styles)

To define a stack on screen where notifications appear. The default
(which can be changed) is:

```coffee
notr.defineStack('def', 'body', {top:'65px', right:'15px'})
```

args        | desc
:---------- | :-----------------
`name`      | Name of the stack. The default notification stack is `"def"`
`parent`    | `document.querySelector` or element of where to `.appendChild` the stack.
`styles`    | `el.style` styles to define for the stack.

#### Default CSS styles

The notr default styles can be altered by overriding the default `.notr` css rule.

However. Notr uses the `margin-top` and `opacity` css style to do the
transition animation. It's probably a bad idea to alter this value.

```css
.notr {
    margin-top: 0; // do not change margin-top
    opacity: 1.0;  // do not change opacity
    float: left;   // probably a bad idea to change
    clear: both;   // probably a bad idea to change
    transition: margin-top 0.2s, opacity 0.2s;

    min-width: 270px;
    min-height: 50px;
    margin-bottom: 3px;
    background: white;
    border: 1px solid #999;
    padding: 5px;
    box-shadow: 0 0 3px rgba(0,0,0,0.4);
    cursor: pointer;
}
.notrstack {
    position: fixed;
    min-width: 270px;
    min-height: 50px;
    z-index: 9000;
}
```

#### Events

Some DOM events that are dispatched on the returned `<div>`.

event             | desc
:---------------- | :-----------------
`notr:beforeshow` | Before showing.
`notr:show`       | When showing.
`notr:beforehide` | Before hiding. Just before `opts.callback`.
`notr:hide`       | After hiding.

Example

```javascript
el = notr('Hi there')
el.addEventListener('notr:show', function() {
    console.log('here we go');
});
```

License
-------

The MIT License (MIT)

Copyright © 2015 TT Nyhetsbyrån

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
