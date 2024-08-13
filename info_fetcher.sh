#!/usr/bin/env bash

logic(){
    # Define values
    song=$(spotifycli --statusposition)
    strippablesong="$song"
    album=$(spotifycli --album)
    artist=$(spotifycli --artist)

    # Strip song information
    newsong="${strippablesong//$artist/}"

    # Print results with proper formatting
    printf " = Song:\n%s\n = Album:\n%s\n = Artist:\n%s\n" "$newsong" " - $album" " - $artist"
}

logic
