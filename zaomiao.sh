#!/bin/sh

# 提示用户选择操作
read -p "请选择：(1) 输入新的参数并保存; (2) 使用上次保存的参数; (3) 重新下载可执行文件: " choice

if [[ $choice -eq 1 ]] || [[ $choice -eq 3 ]]; then
    # 从 GitHub API 获取最新的 release 信息
    latest_release=$(curl --silent "https://api.github.com/repos/Hoshinonyaruko/go-opqcq/releases/latest")

    # 从返回的 JSON 数据中解析出下载 URL
    download_url=$(echo $latest_release | jq -r .assets[0].browser_download_url)

    # 下载可执行文件
    wget -O test-android-arm64 $download_url

    # 修改权限
    chmod +x test-android-arm64
fi

if [[ $choice -eq 1 ]]; then
    # 提示用户输入参数并检查
    read -p "请输入监听api请求的端口（默认8081）:" api_port
    if [[ -z "$api_port" ]]; then
        api_port=8081
    elif ! [[ $api_port =~ ^[0-9]+$ ]] || ((api_port < 5000)) || ((api_port > 65536)); then
        echo "输入的端口号必须在5000-65536范围内的整数"
        exit 1
    fi

    read -p "请输入端口号（必须在20001-20150范围内的整数）:" wsurlb_port
    if ! [[ $wsurlb_port =~ ^[0-9]+$ ]] || ((wsurlb_port < 20001)) || ((wsurlb_port > 20150)); then
        echo "输入的端口号必须在20001-20150范围内的整数"
        exit 1
    fi

    read -p "请输入机器人的QQ号:" qq
    if ! [[ $qq =~ ^[0-9]+$ ]]; then
        echo "QQ号必须是整数"
        exit 1
    fi

    read -p "请输入apiport的值（默认8086）:" user_api_port
    if [[ -z "$user_api_port" ]]; then
        user_api_port=8086
    elif ! [[ $user_api_port =~ ^[0-9]+$ ]] || [ $user_api_port == $api_port ]; then
        echo "apiport的值必须是整数且不能与ws_server的port值重复"
        exit 1
    fi

    read -p "进入QQ群749890922，使用机器人QQ号发送token，留意私信获取你的token:" token
    if [[ ${#token} -ne 32 ]]; then
        echo "Token长度必须为32位"
        exit 1
    fi

    # 保存参数
    echo -e "$api_port\n$wsurlb_port\n$qq\n$user_api_port\n$token" > params.txt

elif [[ $choice -eq 2 ]]; then
    # 读取保存的参数
    if [ -f params.txt ]; then
        readarray -t params < params.txt
        api_port=${params[0]}
        wsurlb_port=${params[1]}
        qq=${params[2]}
        user_api_port=${params[3]}
        token=${params[4]}
    else
        echo "没有找到保存的参数，请重新运行脚本并选择输入新的参数。"
        exit 1
    fi
elif [[ $choice -eq 3 ]]; then
    # 无需进行额外操作，因为已在上面的if语句中下载了最新的可执行文件
    :
else
    echo "无效的选择，请重新运行脚本并选择(1)，(2)或(3)。"
    exit 1
fi

# 运行可执行文件
./test-android-arm64 -ws_server ws://127.0.0.1:$api_port -wsurlb ws://101.35.247.237:$wsurlb_port -qq $qq -api_port $user_api_port -token $token
