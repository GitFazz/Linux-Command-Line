#!/bin/bash

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>debug.log 2>&1

prev=IFS
IFS=$'\n'


output_file="output"
csv_file="output.csv"

# testing............................

if [[  $# =  1  ]]; then
	work_dir=''
	inp_file=$1

elif [[ $# = 2 ]]; then
	work_dir=$1
	inp_file=$2

else
	echo "Give a valid input"
	exit
fi





if test -f "$inp_file"; then
    echo ""
else
	echo "Input file does not exists!"
	exit
fi

#...................end.........................



mkdir "$output_file"
touch "$csv_file"


echo "File Path,Line Number,Line Containing Searched String" >> "$csv_file"




where=$(sed -n '1p' < "$inp_file")
lines=$(sed -n '2p' < "$inp_file")
target=$(sed -n '3p' < "$inp_file")

if [[  $# =  1  ]]; then
	filelist=`grep -wirl "${target}"`
elif [[ $# = 2 ]]; then
	filelist=`grep -wirl "${target}" "$work_dir"`
fi







for pathname in $filelist; do
 	

	if [ "$where" = "begin" ]; then
		line_number=$(head -n "$lines" "$pathname" | grep -n -i -m1 "$target" | cut -d':' -f1)
		line_contains=$(head -n "$lines" "$pathname" | grep -i -m1 -h "$target")

		all_lines=`head -$lines $pathname | grep -win "$target"`
		
		

	    for i in $all_lines
	    do
			csvar2=${i%%:*} 
	    	csvar3=`head -$csvar2 $pathname | tail -1`
	    	echo "${pathname},${csvar2},\"${csvar3}\"" >> "$csv_file"
	    done



	else
		
		line_number=$(tail -n  "$lines" "$pathname"  |  tac | grep -n -i -h -m1 "$target"  |    cut -d':' -f1 )
		line_contains=$(tail -n "$lines" "$pathname"  | tac | grep -i -m1  "$target" )

		all_lines=`tail -$lines $pathname | grep -win "$target"`
		
		

	    for i in $all_lines
	    do
			csvar2=${i%%:*} 
			total=$(wc -l "$pathname" | cut -d' ' -f1)
			total=$(echo $(( total - lines )))
			if [[ $total -lt 0 ]]; then
				#statements
				total=0;
			fi
			csvar2=$(echo $(( total + csvar2 )))
	    	csvar3=`head -$csvar2 $pathname | tail -1`
	    	echo "${pathname},${csvar2},\"${csvar3}\"" >> "$csv_file"
	    done
	fi



	if [ -n "$line_number" ]; then
    	#echo $filename

    	if [ "$where" = "end" ]; then
        	total=$(wc -l "$pathname" | cut -d' ' -f1)
			line_number=$(echo $(( total - line_number + 1)))
			
		fi
    	
    	
    	
    	extension="$(echo ${pathname}.  | cut -d '.' -f 2)"



    	if [[ -n "$extension" ]]; then
    		extension=".${extension}"
    	fi
    	
    	filename=$(echo $pathname | cut -d '.' -f 1 | sed -e 's/\//./g' -e 's/ //g')


    	newfilename="${output_file}/${filename}_${line_number}${extension}"

    	touch $newfilename
    	cp "$pathname" "$newfilename"

	fi



   

done



