#!/bin/bash

image_dir=$1

for image in "$image_dir"/*.jpg; do
    # Use identify to get image dimensions (width x height)
    dimensions=$(identify -format "%w %h" "$image")

    # Extract width and height
    width=$(echo "$dimensions" | cut -d' ' -f1)
    height=$(echo "$dimensions" | cut -d' ' -f2)

    # Compare width and height to determine if it's a landscape image
    if [ "$width" -gt "$height" ]; then
      echo "Landscape image: $image ($width x $height )"
      if [ $width -gt 1024 ]; then
        $(mogrify -resize 1024x\> $image)
      fi
    else
      echo "Portrait image: $image ($width x $height )"
      if [ $height -gt 1024 ]; then
        $(mogrify -resize x1024\> $image)
      fi
    fi
done
