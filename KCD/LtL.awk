
BEGIN {
    FS="\t"
	printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	printf "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
	printf "<plist version=\"1.0\">\n"
	printf "<array>\n"
}

$1 ~ /[0-9]/ {
	printf "\t<dict>\n"
	printf "\t\t<key>weekday</key>\n"
	printf "\t\t<integer>%s</integer>\n", $1
	printf "\t\t<key>equipment</key>\n"
	printf "\t\t<string>%s</string>\n", $2
	printf "\t\t<key>secondShip</key>\n"
	printf "\t\t<string>%s</string>\n", $3
	if($6) {
		printf "\t<key>remodelEquipment</key>\n"
		printf "\t<string>%s</string>\n", $6
	}
	printf "\t</dict>\n"
}

END {
	printf "</array>\n"
	printf "</plist>\n"
}
