#!/usr/bin/fish
#
# Fast cpnversion to mp3

set tmpdir (mktemp -d)

function ext
	echo $argv[1] | sed 's/.*[\.]\([^.]*\)$/\1/'
end

function splitter
	echo "Split " $argv[1]

	set fext (ext $argv[1])

	for i in (seq 0 30)
		set skip (echo "$i * 600" | bc)
		set out (echo $i | xargs printf "out%03d.$fext")
		set out $tmpdir/$out
		echo out $out
		ffmpeg -y -t 600 -ss $skip -i "$argv[1]" -c copy $out 2>/dev/zero >/dev/zero
		ffmpeg -y -i $out $out.mp3 >/dev/zero 2>&1 < /dev/null &
	end

	wait
end

function concat
	set ffmt "concat:"
	set fext ""
	for i in *mp3
		set fext (ext $i)
		set ffmt $ffmt$i'|'
	end

	set ffmt (echo $ffmt | sed 's/|$//')

	ffmpeg -i "$ffmt" -c copy result.$fext 2>&1 >/dev/null
end

splitter $argv[1]

echo tmpdir=$tmpdir

cd $tmpdir
pwd
concat out

cd -
pwd
cp $tmpdir/result* ./$argv[1].mp3

rm -r $tmpdir
