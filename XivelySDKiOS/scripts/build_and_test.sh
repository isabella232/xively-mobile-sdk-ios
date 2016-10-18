#!/bin/bash

#Set up oclint
export LIB_DIR=$(dirname "$0")/../lib
export OCLINT_HOME=$LIB_DIR/oclint-0.8.1-x86_64-darwin-14.0.0/oclint-0.8.1
export PATH=$OCLINT_HOME/bin:$PATH

if [ -d '/xcode_7/Xcode.app/' ]; then
	XCODEBUILD=/xcode_7/Xcode.app/Contents/Developer/usr/bin/xcodebuild
	XCRUN=/xcode_7/Xcode.app/Contents/Developer/usr/bin/xcrun
else 
	XCODEBUILD=xcodebuild
	XCRUN=xcrun
fi


hash oclint &> /dev/null
if [ $? -eq 1 ]; then
	echo >&2 "oclint not found, analyzing stopped"
	exit 1
fi

function cleanBuildAnalyze() {
	echo "Building $1..."
	$XCODEBUILD -configuration Debug -workspace XivelySDKiOS.xcworkspace -scheme $1 -sdk iphonesimulator clean build || exit 1
	echo "Analyzing $1 with XC analyzer..."
	rm -rf xcodebuild.log
	rm -rf analysis.txt
	$XCODEBUILD -configuration Debug -project $2 -target $1 -sdk iphonesimulator clean build analyze 2> analysis.txt | tee xcodebuild.log
	cat analysis.txt
	echo "Tesing $1 analyzer result..."
	grep -F "The following commands produced analyzer issues:" analysis.txt && exit 1
	#echo "Analyzing $1 with OCLint analyzer..."
	#oclint-xcodebuild
	#if [ $# -eq 0 ]
  	#	then sed -i '' 's/-I\. /-I\. -I\/xcode_6_1_gm2\/Xcode\.app\/Contents\/Developer\/Toolchains\/XcodeDefault\.xctoolchain\/usr\/include\/c\+\+\/v1 /g' compile_commands.json
  	#	else sed -i '' 's/-I\. /-I\. -I\/Applications\/Xcode\.app\/Contents\/Developer\/Toolchains\/XcodeDefault\.xctoolchain\/usr\/include\/c\+\+\/v1 /g' compile_commands.json
	#fi
	#sed -i '' 's/-I\. /-I\. -I\/xcode_6_1_gm2\/Xcode\.app\/Contents\/Developer\/Toolchains\/XcodeDefault\.xctoolchain\/usr\/include\/c\+\+\/v1 /g' compile_commands.json
	#oclint-json-compilation-database -- oclint_args "-rc=LONG_LINE=300 -rc=LONG_VARIABLE_NAME=50" | tee oclintanalyze.log
	#echo "Tesing $1 OCLint analyzer result..."
	#grep -F "P1=0" oclintanalyze.log || exit 1
	#echo "Analyzing $1 finished..."
	#rm -rf oclintanalyze.log
	rm -rf xcodebuild.log
	rm -rf analysis.txt
	rm -rf compile_commands.json
}

function test() {
	echo "== $1 testing =="

	$XCODEBUILD test -configuration Debug -workspace XivelySDKiOS.xcworkspace -scheme $1 -sdk iphonesimulator -derivedDataPath derivedData 2>&1 | scripts/ocunit2junit
	cp test-reports/* all-test-reports
	echo "== $1 tested =="
}

cleanBuildAnalyze "common-iOS" "src/common-iOS/common-iOS.xcodeproj"

echo "== Build End =="

mkdir test-reports
rm -rf all-test-reports
mkdir all-test-reports

test "common-iOS"

echo "Analyzing coverage report"
$XCRUN llvm-cov report -instr-profile DerivedData/Build/Intermediates/CodeCoverage/common-iOS/Coverage.profdata DerivedData/Build/Intermediates/CodeCoverage/common-iOS/Products/Debug-iphonesimulator/common-iOSTests.xctest/common-iOSTests >common-iOScoverage.txt
echo "Coverage report done"

REGIONS=$(awk '$1=="TOTAL"{print $2}' common-iOScoverage.txt)
MISS=$(awk '$1=="TOTAL"{print $3}' common-iOScoverage.txt)
CODECOVERAGEB=$(awk '$1=="TOTAL"{print $4}' common-iOScoverage.txt)
FUNCTIONS=$(awk '$1=="TOTAL"{print $5}' common-iOScoverage.txt)
CODECOVERAGEL=$(awk '$1=="TOTAL"{print $6}' common-iOScoverage.txt)
CODECOVERAGEL=$(echo $CODECOVERAGEL | sed 's/%//g')

cd src/common-iOS
ALLLINES=$(git ls-files *.m | xargs cat | wc -l)
ALLLINES=$(($ALLLINES))

cd ../..

COVEREDLINES=$(echo $CODECOVERAGEL | sed 's/\.//g')
COVEREDLINES=$(($ALLLINES * $COVEREDLINES / 10000))
COVEREDREGIONS=$(($REGIONS - $MISS))

echo "##teamcity[blockOpened name='Code Coverage Summary']"
echo "##teamcity[buildStatisticValue key='CodeCoverageB' value='$CODECOVERAGEB']" | sed 's/%//g'
echo "##teamcity[buildStatisticValue key='CodeCoverageAbsMCovered' value='$COVEREDREGIONS']"
echo "##teamcity[buildStatisticValue key='CodeCoverageAbsMTotal' value='$REGIONS']"
echo "##teamcity[buildStatisticValue key='CodeCoverageM' value='$CODECOVERAGEB']" | sed 's/%//g'
echo "##teamcity[buildStatisticValue key='CodeCoverageAbsLCovered' value='$COVEREDLINES']"
echo "##teamcity[buildStatisticValue key='CodeCoverageAbsLTotal' value='$ALLLINES']"
echo "##teamcity[buildStatisticValue key='CodeCoverageL' value='$CODECOVERAGEL']"
echo "##teamcity[blockClosed name='Code Coverage Summary']"

