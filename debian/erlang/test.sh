#!/bin/bash
export DEBIAN_FRONTEND=noninteractive # 防止apt-get交互式安装
# 定义包的详细信息
PACKAGE_NAME="erlang"
PACKAGE_TYPE="Programming Language"
REPORT_FILE="report.json"

# 检查包是否已安装
is_package_installed() {
    dpkg -l | grep -qw $PACKAGE_NAME
    return $?
}

# 安装 Erlang 包
install_erlang_package() {
    apt-get update
    apt-get install -y $PACKAGE_NAME
    return $?
}

# 测试 Erlang 的功能
test_erlang_functionality() {
    local initial_dir=$(pwd)
    local temp_dir=$(mktemp -d)
    local erlang_file="${temp_dir}/hello.erl"
    local module_name="hello"
    local erl_output

    # 创建 Erlang 源文件
    cat <<EOF > "$erlang_file"
-module($module_name).
-export([start/0]).

start() ->
    io:format("Hello, Erlang!~n").
EOF

    cd "$temp_dir"
    erl -compile $module_name
    if [[ -f "${module_name}.beam" ]]; then
        erl_output=$(erl -noshell -s $module_name start -s init stop)
        cd "$initial_dir"  # 返回到初始目录
        if [[ "$erl_output" == "Hello, Erlang!" ]]; then
            return 0
        fi
    fi
    cd "$initial_dir"  # 返回到初始目录
    return 1
}

# 生成报告
generate_report() {
    local test_passed=$1
    local os_version=$(cat /proc/version)
    local kernel_version=$(uname -r)
    local package_version=$(dpkg -l | grep $PACKAGE_NAME | head -n 1 | awk '{print $3}')
    local test_name="Erlang Functionality Test"

    local report_content=$(cat <<EOF
{
    "distro": "debian",
    "os_version": "$os_version",
    "kernel_version": "$kernel_version",
    "package_name": "$PACKAGE_NAME",
    "package_type": "$PACKAGE_TYPE",
    "package_version": "$package_version",
    "test_results": [
        {
            "test_name": "$test_name",
            "passed": $test_passed
        }
    ],
    "all_tests_passed": $test_passed
}
EOF
)
    echo "$report_content" > $REPORT_FILE
}

# 主函数逻辑
main() {
    # 检查包是否已安装
    if is_package_installed; then
        echo "Package $PACKAGE_NAME is installed."
    else
        echo "Package $PACKAGE_NAME is not installed. Attempting to install..."
        if install_erlang_package; then
            echo "Package $PACKAGE_NAME installed successfully."
        else
            echo "Failed to install package $PACKAGE_NAME."
            exit 1
        fi
    fi

    # 测试 Erlang 的功能
    if test_erlang_functionality; then
        echo "Erlang is functioning correctly."
        generate_report true
    else
        echo "Erlang is not functioning correctly."
        generate_report false
    fi

    echo "Report generated at $REPORT_FILE"
}

# 执行主函数
main
