---
layout: post
title: "Constructing flags"
category: articles
tags: ["other"]
description: Generating flag SVGs from official specifications using straightedge-and-compass geometry, with full provenance.
---

National flag SVG collections are widely available online, but few provide any provenance. Where did that particular shade of blue come from — a government specification, a Wikipedia edit, or someone's best guess? I wanted to find out.

[Constructible Flags](https://flags.xaviershay.com) is a Haskell project that generates flag SVGs programmatically from official specifications, using straightedge-and-compass-style geometric constructions where possible, with full provenance for every value. It's not particularly *useful*, but I find it *interesting*. Inspired by [Dr Zye's video](https://www.youtube.com/watch?v=w5QSVhgrqVE) on the constructibility of flags, and my earlier [write-up on ruler & compass constructions.](/articles/fun-with-straightedge-and-compass.html)

<figure>
    <img src='/images/flags-screenshot.png' alt='Constructible Flags screenshot' />
    <figcaption>Selection of generated flags.</figcaption>
</figure>

Fourteen flags have been implemented so far, ranging from France (three rectangles) to Nepal (the world's only non-rectangular national flag.) Some governments are remarkably precise — Nepal's constitution includes a full geometric construction. Others are surprisingly vague — France's constitution says "blue, white, red" and the rest has been left to design guidelines that have changed over the years.

Every flag on the site has a step-by-step construction viewer. You can scrub through each geometric step and watch construction circles, lines, intersection points, and fills accumulate. This was invaluable during development — when a diagonal line is slightly off, being able to scrub to the exact intersection step that went wrong is much more productive than staring at a final SVG.

Every colour, proportion, and layout is sourced from legislation, constitutional schedules, official design guidelines, with editorial decisions clearly documented. The project provides [W3C PROV-JSON](https://www.w3.org/Submission/prov-json/) for each flag, recording exactly where every value came from. Bangladesh is a good example: the official specification names dyes ("Procion Brilliant Green H-2RS"), which I editorially map to Pantone codes, which are then converted to RGB values by sampling Pantone's website. Each link in that chain is recorded.

<figure>
    <img src='/images/bangladesh-provenance.png' alt='Bangladesh provenance screenshot' />
    <figcaption>Provenance graph for the flag of Bangladesh.</figcaption>
</figure>

## Design Choices

The heart of the project is a free arrow (`FlagA a b`) encoded as a GADT. Flags are defined using Haskell's `proc` notation, which makes them read like geometry instructions:

    design :: Sourced :> es => Eff es (FlagA (Point, Point) Drawing)
    design = do
        (h, w) <- reference "2:3 proportion" flagLaw (2, 3)
        discRatio <- reference "Disc height" flagLaw (3 % 5)
        whiteColor <- impliedReference "White" flagLaw (sRGB24 255 255 255)
        redColor   <- impliedReference "Crimson" flagLaw (sRGB24 188 0 45)
        pure $ proc origin -> do
            (tl, tr, br, bl) <- boxNatural w h -< origin

            center <- intersectLL -< ((tl, br), (tr, bl))
            top <- midpoint -< (tl, tr)
            edge <- rationalMult discRatio -< (center, top)

            bg <- fillRectangle whiteColor -< (tl, tr, br, bl)
            disc <- fillCircle redColor -< (center, edge)

            returnA -< bg <> disc

Why an Arrow instead of a Monad? An Arrow's structure is inspectable *before* you run it. With a monadic computation, the structure of the next step can depend on the result of the previous one — you can't know what comes next without executing it. With an Arrow, the entire computation is a static data structure. The same `FlagA` value gets interpreted multiple ways: `eval` produces SVG geometry, `steps` extracts a flat list of primitives for cost counting, `evalTree` records each step for the interactive viewer, and `evalLabels` collects named points. Add a new flag and you automatically get all of those outputs from one `proc` block.

This matters because the construction steps *are the point*. Consider how `midpoint` is implemented:

    midpoint :: FlagA (Point, Point) Point
    midpoint = group "Midpoint" $ proc (a, b) -> do
      -- Two circles of equal radius (|ab|) centered at a and b
      (p, q) <- intersectCC -< ((a, b), (b, a))
      -- The line (p, q) is the perpendicular bisector; intersect with (a, b)
      m <- intersectLL -< ((p, q), (a, b))
      returnA -< m

This is *not* `(a + b) / 2`. It's the classic compass-and-straightedge construction: draw two circles of equal radius, connect their intersections to get the perpendicular bisector, then intersect with the original segment. Same point, but the construction is visible in the data structure and in the interactive viewer.

<figure>
    <img src='/images/flags-viewer.png' alt='Interactive viewer for flag construction' />
    <figcaption>Interactive debug viewer for flag of Jordan.</figcaption>
</figure>

Provenance is handled with a custom algebraic effect `Sourced` built on the [`effectful`](https://hackage.haskell.org/package/effectful) library. Flag definitions carry a `Sourced :> es` constraint and source their values with calls like `reference` and `impliedReference`. The same code runs under different interpreters: `runSourcedPure` strips the metadata and just returns values for rendering, while `runSourcedCollect` accumulates every sourced element for the PROV-JSON generator. The flag definition doesn't change; only the interpreter does.

I initially tried representing all coordinates with exact algebra — constructible numbers are algebraic, so in principle you could avoid floating-point entirely. In practice, this led to exponential blowups (expressions like `sqrt(2) + sqrt(3)` nested through hundreds of construction steps). So I backed off to `Double` as the computational substrate, but kept a `Field` tag tracking what algebraic field each number *should* inhabit: `FInteger`, `FRational`, `FIrrational`, and so on. The tag propagation is conservative — `cos(π/3) = 0.5` gets tagged `FCyclomatic` even though the result is rational — but it gives *some* insight into the mathematical character of each construction while keeping things tractable. It also serves as an abstraction layer if I ever want to try exact algebra again.

## Constructibility

In classical geometry, a *constructible* figure is one you can draw with only an unmarked straightedge and a compass. You can bisect angles, find midpoints, draw perpendiculars — all without measuring. A lot of flag geometry falls into this category.

The project uses three geometric primitives that correspond to what a straightedge and compass allows: line-line intersection, line-circle intersection, and circle-circle intersection. Some flags are fully constructible this way, for example Japan, France, Bangladesh, and Greenland. Others require `NGonVertex` for regular polygons that can't be constructed with compass and straightedge, like Australia or Jordan's 7-pointed stars. Some, like Bhutan, use `SVGOverlay` for non-geometric elements like coats of arms. The site badges each flag with its construction methods and total step cost so you can see at a glance what's involved. A complete list of geometry and rendering primitives is [documented here.](https://flags.xaviershay.com/construction.html)

The source is on [GitHub](https://github.com/xaviershay/constructible-flags) and the site is live at [flags.xaviershay.com](https://flags.xaviershay.com).
