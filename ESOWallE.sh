#!/bin/bash
# 

# The url to your ESO documents directory on steam

DIRSteamESO="/path/to//SteamLibrary/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online/live"

# Change the EU in the URLBaseTTC with US if you are from a certain 3rd world country

URLBaseTTC="https://eu.tamrieltradecentre.com/download/PriceTable"

# Minion 

# Minion currently only runs under proprietary Java Orcale 8
# You need to manually download the Java 8 files from here : 

# Current - Testing
# Version : Java jre1.8.0_391
# Release date : 20 October 2023
# Direct : https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249192_b291ca3e0c8548b5a51d5a5f50063037
# Source : https://www.itechtics.com/java-8-update-391/

# Current - Stable
# Version : Java jre1.8.0_381
# Release date : 20 July 2023
# Direct : https://javadl.oracle.com/webapps/download/AutoDL?BundleId=248763_8c876547113c4e4aab3c868e9e0ec572
# Source : https://www.itechtics.com/java-8-update-381/

PATHBinaryJava="/path/to/Java/jre1.8.0_391/bin/java"
PATHBinaryMinion="/path/to/Minion/Minion-jfx.jar"

############################################################
############################################################
############################################################

# Nothing below this needs manual editing !

############################################################
############################################################
############################################################

URLBaseHarvestMap="http://harvestmap.binaryvector.net:8081"

## Check for command line arguments
## https://www.golinuxcloud.com/bash-script-multiple-arguments/

ESOSCRIPT_DEBUG=FALSE

while [ ! -z "$1" ]; do

  case "$1" in

	## Check for debug enablers
  
    --debug|-d|-D)
        
		shift

		ESOSCRIPT_DEBUG=TRUE
    
	;;

	## Ignore the rest

     :*)
        ## Some command
        ;;

	esac

	shift

done

# Download TTC data overriding any files that already exist

echo -e
echo -e
echo -e "Downloading Tamriel Trade Center Data"
echo -e

curl -# -o "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip" "$URLBaseTTC" 

echo -e

# Having a peek at the content

if [ "$ESOSCRIPT_DEBUG" = TRUE ]

then

	echo  "Previewing : TTC Data"
	echo -e

	# gzip -l "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip"

	bsdtar --list --file "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip"

	echo -e

fi

# Unzipping the TTC temp data while overriding any existing data

if [ "$ESOSCRIPT_DEBUG" = TRUE ]

then

	echo -e "Unzipping : ${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip"
	echo -e

	bsdtar --extract --verbose --file "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip" --directory "${DIRSteamESO}/AddOns/TamrielTradeCentre"
#	gzip -o "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip" -d "${DIRSteamESO}/AddOns/TamrielTradeCentre"

	echo -e

else

	bsdtar --extract --file "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip" --directory "${DIRSteamESO}/AddOns/TamrielTradeCentre"

#	gzip -o "${DIRSteamESO}/AddOns/TTC_TempPriceDataDownload.zip" -d "${DIRSteamESO}/AddOns/TamrielTradeCentre" > /dev/null

fi

# Harvest Map

# Uploading current player data ( important for new zones or new spawn locations you find )
# Downloading new data from the cloud about what spawn locations other poeple found

echo -e "Downloading Harvest Map Data"
echo -e 

# check if everything exists

 if [[ ! -e "${DIRSteamESO}/AddOns/HarvestMapData/" ]]; then echo "ERROR: ${DIRSteamESO}/AddOns/HarvestMapData/ does not exists, re-install HarvestMap and try again...";exit 1;fi

# iterate over the different zones

 for zone in AD EP DC DLC NF; do 

 	fn=HarvestMap${zone}.lua

 	echo "Working on ${fn}..."

 	#svfn1=${savedvardir}/${fn}
 	#svfn2=${svfn1}~

 	svfn1="${DIRSteamESO}/SavedVariables/${fn}"
 	svfn2=${svfn1}~    

	# if saved var file exists, create backup...
 	if [[ -e ${svfn1} ]]; then
 		mv -f "${svfn1}" "${svfn2}"
	# ...else, use empty table to create a placeholderif 
 	else 

 		name=Harvest${zone}_SavedVars

 		#echo -n ${name} | cat - "${emptyfile}" > "${svfn2}"

        echo -n ${name} | cat - "${DIRSteamESO}/AddOns/HarvestMapData/Main/emptyTable.lua" > "${svfn2}"

 	fi

	# download data

    curl -f -# -d @"${svfn2}" -o "${DIRSteamESO}/AddOns/HarvestMapData/Modules/HarvestMap${zone}/${fn}" "${URLBaseHarvestMap}"
	
 done


# Launch Minion

echo -e 
echo -e "Launching Minion"
echo -e 

${PATHBinaryJava} -jar ${PATHBinaryMinion} > /dev/null
