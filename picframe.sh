#!/bin/bash


########################################################################
#  A simple utility to allow you to have a picture frame as a conky
#  object.
#  Originally by Anjishnu Sarkar
#  Largely as found from https://ubuntuforums.org/showthread.php?t=1609575
#  Added option to allow for random picture choosing and install script
#  by Steven Saus
#
########################################################################

## Variables
IdealImgWidth=136
IdealImgHeight=102
Angle=15
Frame="True"
Version=1.0

ConkyFolder="$HOME"/.conky
OutputFile="$ConkyFolder"/pix/image.png
PicFrameConky="$ConkyFolder"/picframe.conkyrc
Alignment="bottom_right"
XGap=10
YGap=10
ScriptName=$(basename $0)
HelpText="Usage:
$ScriptName [options] -i <imagefile>

Options:
-h|--help               Show this help and exit.
-r|--rotate  <angle>    Rotate image by an angle <angle>. Default: 15 degrees.
-nf|--no-frame          No frame. Default has frame.
-a|--alignment          Image alignment position. Options are top_left, 
                        top_right, top_middle, bottom_left, bottom_right, 
                        bottom_middle, middle_left, middle_middle, 
                        middle_right, or none (also can be abreviated as 
                        tl, tr, tm, bl, br, bm, ml, mm, mr)
                        Default: bottom_right
-x-gap <x-gap>          Gap, in pixels, between right or left border of screen.
                        Default: 10
-y-gap <y-gap>          Gap, in pixels, between top or bottom border of screen.
                        Default: 10
-v|--version            Show version number and exit.
"
ErrMsg="$ScriptName: Unspecified option. Aborting."

while test -n "${1}"
do
    case "${1}" in
    -h|--help)      echo -n "$HelpText"
                    exit 0 ;;
    -i|--input)     InputFile="$2"
                    shift ;;
    -r|--rotate)    Angle="$2"
                    shift ;;
    -nf|--no-frame) Frame="False"
                    ;;
    -a|--alignment) Alignment="$2"
                    shift ;;
    -x-gap)         XGap="$2"
                    shift ;;
    -y-gap)         YGap="$2"
                    shift ;;
    -v|--version)   echo ""$ScriptName": Version "$Version"" 
                    exit 0 ;;
        *)          echo "$ErrMsg"
                    exit 1 ;;
    esac
    shift
done

if [ -d "$InputFile" ];then
	# Simple, but doesn't allow subdirs
	# ls -1 "$InputFile" | sort --random-sort | head -1

	InputFile=`find -H "$InputFile" -type f \( -name "*.jpg" -or -name "*.png" -or -name "*.jpeg" \) | sort --random-sort | head -1`
fi

if [ ! -f "$InputFile" ];then
    echo "Image file not found. Aborting."
    exit 1
else
    mkdir -p "$ConkyFolder"/pix/
fi

if [ "$Frame" == "True" ];then
    convert "$InputFile" -resize "$IdealImgWidth"x"$IdealImgHeight"'>' \
        -mattecolor black -frame 9x9+3+3 \
        -background none -rotate $Angle \
        "$OutputFile"
else
    convert "$InputFile" -resize "$IdealImgWidth"x"$IdealImgHeight"'>' \
        -background none -rotate $Angle \
        "$OutputFile"
fi

ImgWidth=$(identify -format %w "$OutputFile")
ImgHeight=$(identify -format %h "$OutputFile")

cat > "$PicFrameConky" << EOF


update_interval 1
total_run_times 0
net_avg_samples 2

override_utf8_locale yes

double_buffer yes
no_buffers yes

text_buffer_size 2048
imlib_cache_size 0

# temperature_unit celcius

# — Window specifications — #

own_window yes
own_window_type override
own_window_transparent yes
own_window_hints undecorated,sticky,skip_taskbar,skip_pager

border_inner_margin 0
border_outer_margin 0

minimum_size $ImgWidth $ImgHeight
# maximum_width 175

alignment ${Alignment}
gap_x ${XGap}
gap_y ${YGap}

# — Graphics settings — #
draw_shades no
draw_outline no
draw_borders no
draw_graph_borders no

# — Text settings — #
use_xft yes
xftfont Bitstream Vera Sans Mono:size=9
xftalpha 0.8

default_color FFFFFF
default_gauge_size 47 25

uppercase no
use_spacer right

color0 white
color1 orange
color2 green

TEXT
\${image ${OutputFile} -p 0,0 -s ${ImgWidth}x${ImgHeight}}
EOF