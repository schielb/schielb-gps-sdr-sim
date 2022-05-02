#!/bin/bash
# Complete arg test

lat=40.25715639520775 # lat and lon for the BYU football stadium
lon=-111.65485471526306
day=$(date +%j)
year=$(date +%Y)
yr=$(date +%y)

latmin=-90.0
latmax=90.0

lonmin=-180.0
lonmax=180.0

daymin=1
daymax=366

yrmin=1992
yrmax=$(date +%Y)

radio="hackrf"

justrun=0
justgen=0

jumpto ()
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}


print_help () {
echo "Usage: genAndRun [options]"
echo "Options:"
echo "  --help            Print this menu."
echo ""
echo "  --date <day year> Enter the day [1, 366] and year [1992, $(date +%Y)] of"
echo "                    the data you want; keep in mind that the day '366' will"
echo "                    only work on a leap year. Typically this option is not"
echo "                    needed, as the default is the current date."
echo ""
echo "  --ll   <lat lon>  Enter the latitude [-90.0, 90.0] and longitude"
echo "                    [-180.0, 180.0] that you wish to simulate from. The"
echo "                    default location is at the BYU football stadium."
echo ""
echo "  --sdr  <radio>    Enter the type of software-defined radio hardware you"
echo "                    are using; currently only supports 'hackrf' (default)" 
echo "                    and 'usrp'."
echo ""
echo "  --just <step>     If 'just' one step is desired, enter it here. Steps are:"
echo "                    'gen': gather a brdc file and generate the .bin" 
echo "                    'run': run the current .bin on the desired sdr"
}

############### STEP 1: Verify any arguments/options being given ####################################################################
while [ $# -gt 0 ]; do
case "${1}" in
    # THIS OPTION IS TO SET THE GPS LOCATION; EXPECTING FLOAT ARGUMENTS 'LAT' AND 'LON'
    --ll) echo "Option --ll: Setting the latitude and longitude"
            shift 1 # Move the arguments array
            
            if [ $# -ge 2 ] # make sure we were handed two more arguments
            then
                
                # make sure a number was passed in for the lat (expected X.X)
                if [[ ${1} =~ ^[+-]?[0-9]*\.?[0-9]*$ ]]
                then
                    if [ $(echo "(${1} >= $latmin) && (${1} <= $latmax)" | bc -l) -eq 1 ] # Check in range [-90.0,90.0]
                    then    
                        lat=${1}            # Store the given latitude
                        echo "Setting latitude: "$lat
                        shift 1
                    # ERROR the given lat was out of
                    else
                        echo "Given latitude value out of range [-90.0,90.0]: "${1}
                        echo "Run 'genAndRun --help' for usage"
                        exit 1
                    fi
                # ERROR a non-number was passed for lat
                else
                    echo "Non-number passed in for latitude: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1
                fi

                # make sure a number was passed in for the lon
                if [[ ${1} =~ ^[+-]?[0-9]*\.?[0-9]*$ ]]
                then
                    if [ $(echo "(${1} >= $lonmin) && (${1} <= $lonmax)" | bc -l) -eq 1 ] # Check in range [-180.0,180.0]
                    then    
                        lon=${1}            # Store the given longitude
                        echo "Setting longitude: "$lon
                        shift 1 
                    # ERROR the lon passed was out of the acceptable range
                    else
                        echo "Given longitude value out of range [-180.0,180.0]: "${1}
                        echo "Run 'genAndRun --help' for usage"
                        exit 1
                    fi
                # ERROR a non-number was passed for lon
                else
                    echo "Non-number passed in for longitude: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1
                fi 
                
                echo "Setting lat and lon to" $lat"," $lon
            # ERROR not enough arguments passed...
            else
                echo "Not enough arguments detected for --ll (lat lon)!"
                echo "Run 'genAndRun --help' for usage"
                exit 1
            fi
            
            echo "";;
            
    # THIS OPTION IS TO SET THE SDR BEING USED; EXPECTING SPECIFIC STRING ARGUMENTS "hackrf" or "usrp"        
    --sdr) echo "Option --sdr: Setting the Software Defined Radio"
            shift 1
            case "${1}" in
                hackrf) 
                    radio="hackrf";;
                usrp)
                    radio="usrp";;
                *)
                    echo "Unkown radio type selected; currently only support 'hackrf' and 'usrp'. Entered: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1;;
            esac
                
            echo "Radio set to: ""$radio"
            shift 1
            echo "";;
    
    # THIS OPTION IS TO SET THE DATE; EXPECTING INTEGER ARGUMENTS 'DAY' and 'YEAR'
    --date) echo "Option --date: Setting the day and year"
            shift 1
            
            if [ $# -ge 2 ] # make sure we were handed two more arguments
            then
                # Start with the day
                # make sure a number was passed in for the day (expected 1-366)
                if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] 2>/dev/null;
                then
                    if [ $(echo "(${1} >= $daymin) && (${1} <= $daymax)" | bc -l) -eq 1 ] # Check in range [1,366]
                    then    
                        printf -v day "%03d" ${1}
                        #day=${1}            # Store the given day
                        echo "Setting day: "$day
                        shift 1
                    # ERROR the given day was out of the acceptable range
                    else
                        echo "Given day value out of range [1,366]: "${1}
                        echo "Run 'genAndRun --help' for usage"
                        exit 1
                    fi
                else
                    echo "Non-integer number passed in for day: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1
                fi
                
                # Move on to the year
                # make sure a valid number was passed in for the year (expected 1992-2022)
                if [ -n "${1}" ] && [ "${1}" -eq "${1}" ] 2>/dev/null;
                then
                    if [ $(echo "(${1} >= $yrmin) && (${1} <= $yrmax)" | bc -l) -eq 1 ] # Check in range [1992,2022]
                    then  
                      
                        # Make sure that leap year is okay
                        if [ "$day" -eq "$daymax" -a `expr ${1} % 4` -ne 0 ]
                        then
                            echo "Day is 366 on a non-leap year: "${1}" % 4 = "`expr ${1} % 4`
                            echo "Run 'genAndRun --help' for usage"
                            exit 1
                        fi
                        
                        year=${1}            # Store the given day
                        yr=`expr ${1} % 100`
                        echo "Setting year//yr: "$year"//"$yr
                        shift 1
                    # ERROR the given year was out of the acceptable range
                    else
                        echo "Given year value out of range [1992,$yrmax]: "${1}
                        echo "Run 'genAndRun --help' for usage"
                        exit 1
                    fi
                # ERROR a non-integer number was passed in for the year
                else
                    echo "Non-integer number passed in for year: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1
                fi
                
                echo "Setting day and year to" $day"," $year
            # ERROR not enough arguments detected for date
            else
                echo "Not enough arguments detected for --date (day year)!"
                echo "Run 'genAndRun --help' for usage"
                exit 1
            fi
            
            echo "";;

    
    
    # THIS OPTION IS TO SPECIFY THE STEP TO RUN
    --just) echo "Option --just: Running only the gen or the run step"
            shift 1
            case "${1}" in
                gen) 
                    justgen=1
                    justrun=0
                    echo "gen: Just generating a .bin file without running it on an sdr";;
                run)
                    justgen=0
                    justrun=1
                    echo "run: Just running the current .bin file on the sdr";;
                *)
                    echo "Unkown step selected; currently only support 'gen' and 'run'. Entered: "${1}
                    echo "Run 'genAndRun --help' for usage"
                    exit 1;;
            esac
                
            echo "Radio set to: ""$radio"
            shift 1
            echo "";;
    # THIS OPTION IS TO PRINT THE HELP MESSAGE
    --help) # Print the usage
            
            print_help
            exit 0;;
    *)  echo "Unkown argument detected: "${1}
        echo "Run 'genAndRun --help' for usage"
        exit 1;;
esac
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "System Setup is:"
echo "Date: "$day"/"$year
echo "Lat: "$lat
echo "Lon: "$lon
echo "Radio: "$radio
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

# If we are just running the current .bin file, skip STEP 2
if [ $justrun -eq 1 ]
then    
    echo "Skipping the 'gen' step"
    jumpto step_run
fi


#step_gen:
############### STEP 2: Gather the data from nasa.gov ####################################################################
echo "Gathering data and generating file..."
echo ""

file_name="brdc""$day""0.$yr""n"
zipfile_name=""

# here, nasa.gov switched from .Z zip files in 1992-2014 to .gz files in 2015 and onward; check what we need
if [ $year -le 2014 ]
then
    zipfile_name=$file_name".Z"
else
    zipfile_name=$file_name".gz"
fi


echo ""

# See if the file already exists
if [ -n "$(ls -A brdc_data/$file_name 2>/dev/null)" ]
then
    echo "Current brdc file already downloaded"
else
    echo "Downloading requested brdc file"
    echo "Looking for https://cddis.nasa.gov/archive/gnss/data/daily/$year""/brdc/$zipfile_name"
    curl -c /tmp/cookie --netrc-file ./.netrc -L -f -o "$zipfile_name" "https://cddis.nasa.gov/archive/gnss/data/daily/$year""/brdc/$zipfile_name"
    
    if [ $? -eq 0 ] # If the curl argument was successfull...
    then
        uncompress "$zipfile_name" 
        mv $file_name "brdc_data/$file_name"
        echo "Requested brdc file downloaded"
        echo "File name is: $file_name"
    else
        echo "Could not find brdc file; if using custom date, please verify it"
        echo "Run 'genAndRun --help' for usage"
        exit 1
    fi
fi

echo ""

# Generate .bin file from brdc data
../gps-sdr-sim -e brdc_data/$file_name -l "$lat","$lon",100

if [ "$?" -eq 0 ]
then
    echo ".bin file generated successfully"
else
    echo "File generated incorrectly"
    echo "Run 'genAndRun --help' for usage"
    exit 1
fi

# If we are just genrating a new .bin file, skip STEP 3
if [ $justgen -eq 1 ]
then    
    echo "Skipping the 'run' step"
    jumpto step_end
fi


step_run:
############### STEP 3: Run the .bin on the sdr ####################################################################
echo ""

__='
get_custom:
echo "Would you like to use custom settings on the sdr? (yes/no):"
read custom
'
echo "Running the .bin file on the sdr: "$radio

case "$radio" in
    hackrf)
        hackrf_transfer -t gpssim.bin -f 1575420000 -s 2600000 -a 1 -x 0
        if [ "$?" -eq 0 ]
        then
            echo "hackrf transfer complete"
        else
            echo "Issue on hackrf_transfer!"
            exit 1
        fi
        ;;
    usrp)
        ../gps-sdr-sim-uhd.py -t gpssim.bin -s 2500000 -x 0
        if [ "$?" -eq 0 ]
        then
            echo "usrp transfer complete"
        else
            echo "Issue on usrp transfer!"
            exit 1
        fi
        ;;
    *)
        echo "Whoah! Somewhere the radio var broke!"
        exit 1;;
esac


step_end:
echo ""
echo "Done!"
