::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
::vsim -gui -do run.do

::vsim -c -do run.do


vsim -%5 -do "do run.do %1 %2 %3 %4 %6"
cd ../tools