#!/bin/bash

declare ourpath
declare userbin
declare align1
declare align2
declare rotate

echo "Creating (if needed) $HOME/.conky, $HOME/.conky/pix, and $HOME/.config/picframe"
echo "and proceeding to put conky script in $HOME/.conky/picframe.conkyrc "
echo "Press any key to continue; Ctrl-C to exit."
read
if [ ! -d $HOME/.conky ];then
	mkdir -p $HOME/.conky
fi
	cp picframe.conkyrc $HOME/.conky/picframe.conkyrc

mkdir -p $HOME/.conky/pix
mkdir -p $HOME/.config/picframe

echo "Default is to move the script to $HOME/bin. Do you desire this (Y/n)?"
read
if [ $read == "n" ];then
	ourpath=$PWD
else
	userbin=$(echo $PATH | grep -c "$HOME/bin")
	if [ $userbin -lt 1 ];then
		mkdir -p $HOME/bin
	fi
	chmod +x picframe.sh
	mv picframe.sh $HOME/bin
	ourpath=$HOME/bin
fi

echo "Where do you want the image aligned?"
echo "Top, Bottom, or Middle? (left/right/middle will be the next question)"
read
case "$read" in
	[Tt]) align1=top_;;
	[Bb]) align1=bottom_;;
	[Mm]) align1=middle_;;
	*)	align1=bottom_;;
esac
echo "And second alignment measure?"
echo "Left, Right, or Middle?"
read
case "$read" in
	[Ll]) align2=left;;
	[Rr]) align2=right;;
	[Mm]) align2=middle;;
	*)	align2=right;;
esac

echo "Degrees of rotation?"
read
if [[ $read =~ ^-?[0-9]+$ ]];then
	rotate=$read
else
	rotate=15
fi

echo "Gap from left or right of screen in pixels?"
read
if [[ $read =~ ^-?[0-9]+$ ]];then
	xgap=$read
else
	xgap=10
fi

echo "Gap from top or bottom of screen in pixels?"
read
if [[ $read =~ ^-?[0-9]+$ ]];then
	ygap=$read
else
	ygap=10
fi

echo "Type either the full path of a single image, or the DIRECTORY of images"
echo "to import into the picture frame script."
read
if [ -d "$read" ];then
	find -H "$read" -type f \( -name "*.jpg" -or -name "*.png" -or -name "*.jpeg" -or -name "*.gif" \) -exec cp {} $HOME/.config/picframe  \;
elif [ -f "$read"];then
	cp "$read" $HOME/.conky/pix/image.png
	cp $HOME/.conky/pix/image.png $HOME/.config/picframe
	
else
	curl -o $HOME/.conky/pix/image.png http://unsplash.it/256/256/?random
	cp $HOME/.conky/pix/image.png $HOME/.config/picframe	
fi

echo "Do you want a frame (Y/n)?"
read
if [ $read == "n" ];then
	arg1=$(echo "--no-frame")
fi

#inital run to get us going
$ourpath/picframe.sh $arg1 --rotate $rotate --alignment $align1$align2 -x-gap $xgap -y-gap $ygap



# add rotate to crontab
# (crontab -l ; echo "0 * * * * your_command") | sort - | uniq - | crontab -
/home/steven/bin/picframe.sh -a tl -r 0 -x-gap 0 -i /home/steven/.config/picframe