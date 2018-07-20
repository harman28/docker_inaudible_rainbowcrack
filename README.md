# `docker_inaudible_rainbowcrack`

This is a Dockerfile for automatically recovering your Audible activation data in an offline manner (i.e. without contacting Audible servers), then using it to remove the DRM from your AAX files and losslessly transcode them to M4A audio and copy the cover art.

This is based on: <https://github.com/inAudible-NG/tables>

## Usage

Map a directory containing one or more AAX files to the `/data` volume, then run the container.

For example you could `cd` to a directory containing your AAX files and run:

    docker run -v $(pwd):/data ryanfb/inaudible
