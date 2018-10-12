#!/bin/bash

svnadmin load /data/hub/disk1t/svn/project --parent-dir mobile4.0 < /data/hub/disk4tb/codePro/20181011/mobile4_20181011
svnadmin load /data/hub/disk1t/svn/project --parent-dir mobile3.0 < /data/hub/disk4tb/codePro/20181011/mobile3_20181011
svnadmin load /data/hub/disk1t/svn/project --parent-dir mobile2.0 < /data/hub/disk4tb/codePro/20181011/mobile2_20181011
svnadmin load /data/hub/disk1t/svn/project --parent-dir mobile < /data/hub/disk4tb/codePro/20181011/mobile_20181011
svnadmin load /data/hub/disk1t/svn/project --parent-dir server < /data/hub/disk4tb/codePro/20181011/server_20181011
svnadmin load /data/hub/disk1t/svn/project --parent-dir javaServer < /data/hub/disk4tb/codePro/20181011/javaServer_20181011
