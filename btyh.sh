#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ $(whoami) != "root" ];then
	echo "请使用root权限执行命令！"
	exit 1;
fi
if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
	echo "未安装宝塔面板"
	exit 1
fi 

sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
rm -rf /www/server/panel/data/bind.pl
if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
fi
echo "已去除宝塔面板强制绑定账号."

Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
JS_file="/www/server/panel/BTPanel/static/bt.js";
if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
	sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
fi;
wget -q https://raw.githubusercontent.com/cbingd/bt7.7/main/bt.js -O $JS_file;
echo "已去除各种计算题与延时等待."

sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo "已去除创建网站自动创建的垃圾文件."

rm -f /www/server/panel/data/admin_path.pl
sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo "已关闭未绑定域名提示页面."

sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
echo "已关闭安全入口登录提示页面."

sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo "已去除消息推送与文件校验."


rm /www/server/panel/class/ajax.py
cd /www/server/panel/class
wget https://raw.githubusercontent.com/cbingd/bt7.7/main/ajax.py
rm /www/server/panel/task.py
cd /www/server/panel
wget https://raw.githubusercontent.com/cbingd/bt7.7/main/task.py
rm /www/server/panel/tools.py
cd /www/server/panel
wget https://raw.githubusercontent.com/cbingd/bt7.7/main/tools.py
echo "防止升级结束."

if [ ! -f /www/server/panel/data/not_recommend.pl ]; then
	echo "True" > /www/server/panel/data/not_recommend.pl
fi
if [ ! -f /www/server/panel/data/not_workorder.pl ]; then
	echo "True" > /www/server/panel/data/not_workorder.pl
fi
echo "已关闭活动推荐与在线客服."

plugin_file="/www/server/panel/data/plugin.json"
if [ -f ${plugin_file} ];then
    chattr -i /www/server/panel/data/plugin.json
    rm /www/server/panel/data/plugin.json
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/cbingd/bt7.7/main/plugin.json
    chattr +i /www/server/panel/data/plugin.json
else
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/cbingd/bt7.7/main/plugin.json
    chattr +i /www/server/panel/data/plugin.json
fi
echo "插件商城开心结束."

repair_file="/www/server/panel/data/repair.json"
if [ -f ${repair_file} ];then
    chattr -i /www/server/panel/data/repair.json
    rm /www/server/panel/data/repair.json
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/cbingd/bt7.7/main/repair.json
    chattr +i /www/server/panel/data/repair.json
else
    cd /www/server/panel/data
    wget https://raw.githubusercontent.com/cbingd/bt7.7/main/repair.json
    chattr +i /www/server/panel/data/repair.json
fi
echo "文件防修改结束."

/etc/init.d/bt restart

echo -e "=================================================================="
echo -e "\033[32m宝塔面板优化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7"
echo  "如需还原之前的样子，请在面板首页点击“修复”"
echo -e "=================================================================="
