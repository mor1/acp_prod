#!/bin/bash

# run.sh - run a working set of Rita modules in 'production' mode
#
# These modules configured to use
#
# feedhandler.vix:
#   /media/tfc/vix/data_bin
#   /media/tfc/vix/data_cache
#   /media/tfc/vix/data_monitor
#
# msgfiler.vix.zone_cambridge:
#   /media/tfc/vix/data_bin_json
#   /media/tfc/vix/data_monitor_json
#   /media/tfc/vix/data_zone
#
# dataserver.vix READS:
#   /media/tfc/vix/data_*
#   /media/tfc/vix/data_zone_config (for zone app config files)
#
# feedmaker.cam:
#   /media/tfc/cam/cam_park_local/data_bin
#   /media/tfc/cam/cam_park_local/data_monitor
#   /media/tfc/cam/cam_park_rss/data_bin
#   /media/tfc/cam/cam_park_rss/data_monitor
#
# msgfiler.cam_to_json (for feed_id = cam_park_local & cam_park_rss):
#   /media/tfc/cam/{{feed_id}}/data_bin_json/{{filepath}}
#   /media/tfc/cam/{{feed_id}}/data_monitor_json
#   /media/tfc/cam/{{feed_id}}/data_park/{{ts|yyyy}}/{{ts|MM}}/{{ts|dd}}
#

# Sample 'ps aux | grep vertx' output (from tfc-app2):
#
#tfc_prod  59221  0.3  2.7 14192096 891560 pts/9 Sl   Sep12  40:15 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.console.A -cluster
#tfc_prod  65814  0.2  0.9 14174680 308288 pts/9 Sl   Sep12  29:51 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.dataserver.vix -cluster
#tfc_prod  65975  0.2  1.4 14191060 488692 pts/9 Sl   Sep12  30:41 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.feedmaker.park_local_rss -cluster
#tfc_prod  66238  0.2  0.9 14203412 296388 pts/9 Sl   Sep12  30:05 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.msgfiler.vix.zone_cambridge -cluster
#tfc_prod  66457  0.2  0.8 14188140 272940 pts/9 Sl   Sep12  36:32 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.msgfiler.vix.feed_json -cluster
#tfc_prod  66675  0.2  0.9 14202384 324468 pts/9 Sl   Sep12  29:22 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.msgfiler.cam.to_json -cluster
#tfc_prod  67050  0.6  2.2 14217148 747416 pts/9 Sl   Sep12  77:30 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.zonemanager.cambridge.vix -cluster
#tfc_prod  67289  0.2  0.8 14176736 275768 pts/9 Sl   Sep12  32:06 java -cp tfc_2017-09-12.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.feedhandler.vix -cluster
#ijl20     78007  0.0  0.0  14232  1024 pts/10   S+   09:16   0:00 grep --color=auto vertx
#ijl20    129822  0.0  0.8 12770108 272116 ?     Sl   Apr18 203:32 java -cp target/tfc_server-1.0-SNAPSHOT-fat.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.feedmaker.test.cloudamber_siri_vm
#tfc_prod 138572  0.2  2.3 14213188 756000 pts/9 Sl   Sep13  27:05 java -cp postgresql-42.1.3.jar:tfc_2017-09-13.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.msgrouter.A -cluster
#tfc_prod 139322  0.2  1.5 14167672 518136 pts/9 Sl   Sep13  26:27 java -cp tfc_2017-09-13.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.httpmsg.A -cluster
#tfc_prod 142583  0.2  1.9 14167488 649336 pts/9 Sl   Sep13  24:54 java -cp tfc_2017-09-13.jar io.vertx.core.Launcher run service:uk.ac.cam.tfc_server.everynet_feed.A -cluster

# start vix modules

# If an argument has been given, use tfc<argument>.jar, e.g. ./run.sh _2017-03-31, and this will use tfc_2017-03-31.jar
# Otherwise run.sh will simply use tfc.jar

# CONSOLE
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.console.A" -cluster >/dev/null 2>>/var/log/tfc_prod/console.A.err & disown

# DATASERVER TO PROVIDE DATA API FOR TFC_WEB
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.dataserver.vix" -cluster >/dev/null 2>>/var/log/tfc_prod/dataserver.vix.err & disown

# #############################################################################################
# ################  PARK_LOCAL_RSS FEEDMAKER  #################################################
# #############################################################################################

# FEEDMAKER TO SCRAPE CAR PARK WEB SITES
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.feedmaker.park_local_rss" -cluster >/dev/null 2>>/var/log/tfc_prod/feedmaker.park_local_rss.err & disown

# MSGFILER TO STORE MESSAGES FROM CAR PARKS FEEDMAKER (i.e. from feedmaker.park_local_rss)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgfiler.cam.to_json" -cluster >/dev/null 2>>/var/log/tfc_prod/msgfiler.cam.to_json.err & disown

# #############################################################################################
# ################  VIX GTFS FEEDHANDLER  #####################################################
# #############################################################################################

# FEEDHANDLER FOR VIX GTFS DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.feedhandler.vix" -cluster >/dev/null 2>>/var/log/tfc_prod/feedhandler.vix.err & disown

# MSGFILER TO STORE VIX ZONE TRANSIT MESSAGES
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgfiler.vix.zone_cambridge" -cluster >/dev/null 2>>/var/log/tfc_prod/msgfiler.vix.zone_cambridge.err & disown

# MSGFILER TO STORE VIX JSON GTFS MESSAGES (i.e. from feedhandler.vix, parsed from Google Protobuf)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgfiler.vix.feed_json" -cluster >/dev/null 2>>/var/log/tfc_prod/msgfiler.vix.feed_json.err & disown

# ZONEMANAGER VIX (launches all the Cambridge zone verticles)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.zonemanager.cambridge.vix" -cluster >/dev/null 2>>/var/log/tfc_prod/zonemanager.cambridge.vix.err & disown

# #############################################################################################
# ################  EVERYNET FEED HANDLER  ####################################################
# #############################################################################################

# EVERYNETFEED (receives http PUSH sensor data messages from EveryNet)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.everynet_feed.A" -cluster >/dev/null 2>>/var/log/tfc_prod/everynet_feed.A.err & disown

# MSGROUTER (forwards EveryNet messages to onward destinations)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgrouter.A" -cluster >/dev/null 2>>/var/log/tfc_prod/msgrouter.A.err & disown

# HTTPMSG (command API for tfc_web)
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.httpmsg.A" -cluster >/dev/null 2>>/var/log/tfc_prod/httpmsg.A.err & disown

# #############################################################################################
# ################   VIX GTFS FEEDMAKER  ######################################################
# #############################################################################################

# VIX2 FEEDMAKER FOR GTFS VIX DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.feedmaker.vix2" -cluster >/dev/null 2>>/var/log/tfc_prod/feedmaker.vix2.err & disown

# VIX2 ZONEMANAGER FOR GTFS VIX DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.zonemanager.vix2" -cluster >/dev/null 2>>/var/log/tfc_prod/zonemanager.vix2.err & disown

# VIX2 MSGFILER FOR GTFS VIX DATA AND ZONE TRANSITS
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgfiler.vix2" -cluster >/dev/null 2>>/var/log/tfc_prod/msgfiler.vix2.err & disown

# #############################################################################################
# ################   SIRIVM CLOUDAMBER FEEDMAKER  #############################################
# #############################################################################################

# SIRIVM FEEDMAKER FOR CLOUDAMBER SIRIVM DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.feedmaker.cloudamber.sirivm" -cluster >/dev/null 2>>/var/log/tfc_prod/feedmaker.cloudamber.sirivm.err & disown

# SIRIVM ZONEMANAGER FOR CLOUDAMBER SIRIVM DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.zonemanager.cloudamber.sirivm" -cluster >/dev/null 2>>/var/log/tfc_prod/zonemanager.cloudamber.sirivm.err & disown

# SIRIVM MSGFILER FOR CLOUDAMBER SIRIVM DATA
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgfiler.cloudamber.sirivm" -cluster >/dev/null 2>>/var/log/tfc_prod/msgfiler.cloudamber.sirivm.err & disown

# SIRIVM MSGROUTER (tfc-app2 only)
if [ "$HOSTNAME" = tfc-app2 ]; then
nohup java -cp tfc$1.jar io.vertx.core.Launcher run "service:uk.ac.cam.tfc_server.msgrouter.cloudamber.sirivm" -cluster >/dev/null 2>>/var/log/tfc_prod/msgrouter.cloudamber.sirivm.err & disown
fi

