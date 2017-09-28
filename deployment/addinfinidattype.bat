@echo on
"%VCS_HOME%"\bin\haconf -makerw
"%VCS_HOME%"\bin\hatype -add infinidat
"%VCS_HOME%"\bin\hatype -modify infinidat ArgList localbox UserLocal PasswordLocal remotebox UserRemote PasswordRemote LocalCG RemoteCG
"%VCS_HOME%"\bin\hatype -modify infinidat OpenTimeout 180
"%VCS_HOME%"\bin\hatype -modify infinidat OnlineTimeout 700
"%VCS_HOME%"\bin\hatype -modify infinidat RestartLimit 1
"%VCS_HOME%"\bin\haattr -add infinidat localbox -string
"%VCS_HOME%"\bin\haattr -add infinidat UserLocal -string
"%VCS_HOME%"\bin\haattr -add infinidat PasswordLocal -string
"%VCS_HOME%"\bin\haattr -add infinidat remotebox -string
"%VCS_HOME%"\bin\haattr -add infinidat UserRemote -string
"%VCS_HOME%"\bin\haattr -add infinidat PasswordRemote -string
"%VCS_HOME%"\bin\haattr -add infinidat LocalCG -string 
"%VCS_HOME%"\bin\haattr -add infinidat RemoteCG -string 
"%VCS_HOME%"\bin\haconf -dump -makero
mkdir "%VCS_HOME%"\bin\infinidat
mkdir "%VCS_HOME%"\conf\sample_infinidat
copy ..\Windows\*.pl "%VCS_HOME%"\bin\infinidat
copy ..\Windows\*.pm "C:\program files\Verias\VRTSperl\lib"
copy *.xml "%VCS_HOME%"\bin\infinidat
copy *.dll "%VCS_HOME%"\bin\infinidat
copy *.cf "%VCS_HOME%"\conf\sample_infinidat



