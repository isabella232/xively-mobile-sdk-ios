#!/bin/bash
#Credit for the script goes to Tamas Varady
if [ "$TC_CHKOUT_DIR" = "" ]
then
echo "TC_CHKOUT_DIR is not set, quitting"
exit 1
fi

LOG=$TC_CHKOUT_DIR/iPhoneSimulator.log
FINISHED=$TC_CHKOUT_DIR/build_command_finished.out

if [ -f $LOG ]
then
rm $LOG
fi
if [ -f $FINISHED ]
then
rm $FINISHED
fi

# osascript -e "tell app \"Terminal\" to do script \"cd $TC_CHKOUT_DIR; tc/tc_build_test_ios.rb $@ > $LOG; echo \$? > $FINISHED; exit \$?\""

osascript -e "tell app \"Terminal\" to do script \"cd $TC_CHKOUT_DIR; scripts/build_and_test.sh $@ > $LOG; echo \$? > $FINISHED; exit \$?\""

# osascript returns immediately after invoking Terminal, so we have to wait for completion of the build
WAITCOUNTER=0
while [ ! -f $FINISHED ];
do
sleep 1
(( WAITCOUNTER++ ))
if [ $WAITCOUNTER = 900 ]
then
echo "timeout"
break
fi
done

ERRORCODE=1
if [ -f $FINISHED ]
then
FILE_DATA=( $( /bin/cat $FINISHED ) )
ERRORCODE=$FILE_DATA
fi
rm $FINISHED

osascript -e 'tell app "iOS Simulator" to quit'
echo "Showing log:"
cat $LOG
echo "Exiting with error code $ERRORCODE"
exit $ERRORCODE