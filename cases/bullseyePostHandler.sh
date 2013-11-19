#!/bin/bash

sessionId=$1
codeCoverageOn=$2
	
if [[ -z "$codeCoverageOn" ]];then
	exit 0
fi

echoPrefix=`basename $0`
coverageDir=$COVFILES_REPO_DIR/$sessionId
coverageResultDir=$coverageDir/$RESULTS_DIRNAME

mergedCovfileTemp=$JXIO_DIR/${MERGED_COVFILE_PREFIX}${COVFILE_SUFFIX}
echo "$echoPrefix: merge command is: covmerge --create --file $mergedCovfileTemp $coverageResultDir/*${COVFILE_SUFFIX}"
covmerge --create --file $mergedCovfileTemp $coverageResultDir/*${COVFILE_SUFFIX}

codeCoverageSummaryTemp=$JXIO_DIR/$SUMMARY_FILENAME
codeCoverageSummaryFinal=$coverageDir/$SUMMARY_FILENAME
covdir --file $mergedCovfileTemp >> $codeCoverageSummaryTemp

mv $mergedCovfileTemp $coverageDir
mv $codeCoverageSummaryTemp $coverageDir

# commiting the results

echo "$echoPrefix: covselect --file $mergedCovfileTemp -i $COVERAGE_EXCLUDES"
covselect --file $mergedCovfileTemp -i $COVERAGE_EXCLUDES
echo "$echoPrefix: eval $CODE_COVERAGE_COMMIT_SCRIPT_PATH --branch $GIT_BRANCH --product $PRODUCT_NAME --team $TEAM_NAME --version $VERSION_SHORT_FORMAT --path $coverageResultDir"
if [[ -z $BULLSEYE_DRYRUN ]];then
	eval $CODE_COVERAGE_COMMIT_SCRIPT_PATH --branch $GIT_BRANCH --product $PRODUCT_NAME --team $TEAM_NAME --version $VERSION_SHORT_FORMAT --path $coverageResultDir
else
	echo "$echoPrefix: dry-run mode - the coverage-report won't be sent"
fi


