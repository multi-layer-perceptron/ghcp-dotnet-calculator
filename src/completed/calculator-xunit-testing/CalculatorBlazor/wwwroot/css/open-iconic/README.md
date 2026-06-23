# [Open Iconic v1.1.1](https://github.com/iconic/open-iconic)

\n\nOpen Iconic is the open source sibling of [Iconic](https://github.com/iconic/open-iconic). It is a hyper-legible collection of 223 icons with a tiny footprint&mdash;ready to use with Bootstrap and Foundation. [View the collection](https://github.com/iconic/open-iconic)

\n\nWhat's in Open Iconic?

\n\n223 icons designed to be legible down to 8 pixels
\n\nSuper-light SVG files - 61.8 for the entire set
\n\nSVG sprite&mdash;the modern replacement for icon fonts
\n\nWebfont (EOT, OTF, SVG, TTF, WOFF), PNG and WebP formats
\n\nWebfont stylesheets (including versions for Bootstrap and Foundation) in CSS, LESS, SCSS and Stylus formats
\n\nPNG and WebP raster images in 8px, 16px, 24px, 32px, 48px and 64px.

\n\nGetting Started

\n\nFor code samples and everything else you need to get started with Open Iconic, check out our [Icons](https://github.com/iconic/open-iconic) and [Reference](https://github.com/iconic/open-iconic) sections.

\n\nGeneral Usage

\n\nUsing Open Iconic's SVGs

We like SVGs and we think they're the way to display icons on the web. Since Open Iconic are just basic SVGs, we suggest you display them like you would any other image (don't forget the `alt` attribute).

```

text

<img src="/open-iconic/svg/icon-name.svg" alt="icon name">

```

text
text

\n\nUsing Open Iconic's SVG Sprite

Open Iconic also comes in a SVG sprite which allows you to display all the icons in the set with a single request. It's like an icon font, without being a hack.

Adding an icon from an SVG sprite is a little different than what you're used to, but it's still a piece of cake. _Tip: To make your icons easily style able, we suggest adding a general class to the_ `<svg>` _tag and a unique class name for each different icon in the_ `<use>` _tag._

```

text

<svg class="icon">

  <use xlink:href="open-iconic.svg#account-login" class="icon-account-login"></use>

</svg>

```

text
text

Sizing icons only needs basic CSS. All the icons are in a square format, so just set the `<svg>` tag with equal width and height dimensions.

```

text

.icon {

  width: 16px;

  height: 16px;

}

```

text
text

Coloring icons is even easier. All you need to do is set the `fill` rule on the `<use>` tag.

```

text

.icon-account-login {

  fill: #f00;

}

```

text
text

To learn more about SVG Sprites, read [Chris Coyier's guide](http://css-tricks.com/svg-sprites-use-better-icon-fonts/).

\n\nUsing Open Iconic's Icon Font...

\n\n…with Bootstrap

You can find our Bootstrap stylesheets in `font/css/open-iconic-bootstrap.{css, less, scss, styl}`

```

text

<link href="/open-iconic/font/css/open-iconic-bootstrap.css" rel="stylesheet">

```

text
text

```

text

<span class="oi oi-icon-name" title="icon name" aria-hidden="true"></span>

```

text
text

\n\n…with Foundation

You can find our Foundation stylesheets in `font/css/open-iconic-foundation.{css, less, scss, styl}`

```

text

<link href="/open-iconic/font/css/open-iconic-foundation.css" rel="stylesheet">

```

text
text

```

text

<span class="fi-icon-name" title="icon name" aria-hidden="true"></span>

```

text
text

\n\n…on its own

You can find our default stylesheets in `font/css/open-iconic.{css, less, scss, styl}`

```

text

<link href="/open-iconic/font/css/open-iconic.css" rel="stylesheet">

```

text
text

```

text

<span class="oi" data-glyph="icon-name" title="icon name" aria-hidden="true"></span>

```

text
text

\n\nLicense

\n\nIcons

All code (including SVG markup) is under the [MIT License](http://opensource.org/licenses/MIT).

\n\nFonts

All fonts are under the [SIL Licensed](http://scripts.sil.org/cms/scripts/page.php?item_id=OFL_web).

\n
